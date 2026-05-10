#!/usr/bin/env node
/**
 * wiki-mcp — read-only MCP server exposing a kbmap wiki.
 *
 * Reads from $WIKI_PATH (defaults to ../wiki relative to this script).
 * Exposes read tools per the surface defined in mcp-server/README.md.
 * Refuses to start if the wiki/manifest.json has a manifest_version > MANIFEST_VERSION_SUPPORTED.
 *
 * Designed to work standalone OR alongside a separate per-app
 * `app-actions-mcp` server that handles write-side action dispatch. This
 * server NEVER executes actions — it only describes them via describe_action.
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import type { Resource } from "@modelcontextprotocol/sdk/types.js";
import { readFile, stat } from "node:fs/promises";
import { existsSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import matter from "gray-matter";
import { GraphIndex, getGraphNeighborhood, loadGraphIndex, resolveGraphPath } from "./graph.js";
import { retrieveContext } from "./retrieve.js";

const MANIFEST_VERSION_SUPPORTED = 1;

// Resolve WIKI_PATH: env var first, fallback to ../wiki next to this script.
const __dirname = dirname(fileURLToPath(import.meta.url));
const WIKI_PATH = process.env.WIKI_PATH
  ? resolve(process.env.WIKI_PATH)
  : resolve(__dirname, "..", "..", "wiki");
const GRAPH_PATH = resolveGraphPath(WIKI_PATH);

if (!existsSync(WIKI_PATH)) {
  console.error(
    `[wiki-mcp] WIKI_PATH does not exist: ${WIKI_PATH}\n` +
      `Set the WIKI_PATH env var or place this server at <project_root>/mcp-server/.`
  );
  process.exit(2);
}

// ---- Manifest loading + version gate ---------------------------------------

interface ManifestPageEntry {
  slug: string;
  kind: string;
  audience: string[];
  version: number;
  last_updated: string;
  mapped_date: string;
  status: string;
  path: string;
  frontmatter_excerpt?: Record<string, unknown>;
  links_in?: string[];
  links_out?: string[];
}

interface Manifest {
  manifest_version: number;
  generated_at: string;
  project_slug: string;
  kbmap_version: string;
  page_count: number;
  pages: ManifestPageEntry[];
}

let manifest: Manifest | null = null;
let graphIndex: GraphIndex | null = null;

const MANIFEST_RESOURCE_URI = "wiki://manifest";
const PAGE_RESOURCE_PREFIX = "wiki://page/";

async function loadManifest(): Promise<Manifest> {
  const manifestPath = join(WIKI_PATH, "manifest.json");
  if (!existsSync(manifestPath)) {
    throw new Error(
      `[wiki-mcp] No manifest.json at ${manifestPath}. ` +
        `Run /lint in your project to generate one.`
    );
  }
  const raw = await readFile(manifestPath, "utf8");
  const m = JSON.parse(raw) as Manifest;
  if (m.manifest_version > MANIFEST_VERSION_SUPPORTED) {
    throw new Error(
      `[wiki-mcp] manifest_version=${m.manifest_version} is newer than ` +
        `MANIFEST_VERSION_SUPPORTED=${MANIFEST_VERSION_SUPPORTED}. ` +
        `Upgrade the wiki-mcp server or downgrade your wiki manifest.`
    );
  }
  return m;
}

// ---- Page reading ----------------------------------------------------------

interface ParsedPage {
  slug: string;
  kind: string;
  frontmatter: Record<string, unknown>;
  body: string;
  raw: string;
}

async function readPageBySlug(slug: string): Promise<ParsedPage | null> {
  if (!manifest) manifest = await loadManifest();
  const entry = manifest.pages.find((p) => p.slug === slug);
  if (!entry) return null;
  const fullPath = pagePath(entry);
  if (!existsSync(fullPath)) return null;
  const raw = await readFile(fullPath, "utf8");
  const parsed = matter(raw);
  return {
    slug: entry.slug,
    kind: entry.kind,
    frontmatter: parsed.data,
    body: parsed.content,
    raw,
  };
}

function pagePath(entry: ManifestPageEntry): string {
  return join(dirname(WIKI_PATH), entry.path);
}

async function fullTextSearch(
  query: string,
  kindFilter?: string,
  audienceFilter?: string
): Promise<ManifestPageEntry[]> {
  if (!manifest) manifest = await loadManifest();
  const candidates = manifest.pages.filter((p) => {
    if (kindFilter && p.kind !== kindFilter) return false;
    if (audienceFilter && !p.audience.includes(audienceFilter)) return false;
    return true;
  });
  const terms = tokenize(query);
  const phrase = query.trim().toLowerCase();
  const matches: Array<{ entry: ManifestPageEntry; score: number }> = [];
  for (const p of candidates) {
    const fullPath = pagePath(p);
    if (!existsSync(fullPath)) continue;
    const raw = (await readFile(fullPath, "utf8")).toLowerCase();
    const metadataText = [
      p.slug,
      p.kind,
      p.status,
      p.path,
      JSON.stringify(p.frontmatter_excerpt ?? {}),
    ]
      .join(" ")
      .toLowerCase();
    const score = lexicalScore(phrase, terms, metadataText, raw);
    if (score > 0) {
      matches.push({ entry: p, score });
    }
  }
  return matches
    .sort((a, b) => b.score - a.score || a.entry.slug.localeCompare(b.entry.slug))
    .map((match) => match.entry);
}

function tokenize(query: string): string[] {
  return query
    .toLowerCase()
    .split(/[^a-z0-9_-]+/i)
    .map((term) => term.trim())
    .filter((term) => term.length >= 2);
}

function lexicalScore(phrase: string, terms: string[], metadataText: string, bodyText: string): number {
  if (!phrase && terms.length === 0) return 0;
  let score = 0;
  if (phrase && metadataText.includes(phrase)) score += 12;
  if (phrase && bodyText.includes(phrase)) score += 8;

  for (const term of terms) {
    if (metadataText.includes(term)) score += 4;
    if (bodyText.includes(term)) score += 1;
  }

  const matchedTerms = terms.filter((term) => metadataText.includes(term) || bodyText.includes(term));
  if (terms.length > 0 && matchedTerms.length === terms.length) score += 3;
  return score;
}

// ---- Resource handlers -----------------------------------------------------

function pageResourceUri(slug: string): string {
  return `${PAGE_RESOURCE_PREFIX}${encodeURIComponent(slug)}`;
}

function slugFromPageResourceUri(uri: string): string | null {
  if (!uri.startsWith(PAGE_RESOURCE_PREFIX)) return null;
  const encoded = uri.slice(PAGE_RESOURCE_PREFIX.length);
  if (!encoded) return null;
  return decodeURIComponent(encoded);
}

async function listResources() {
  if (!manifest) manifest = await loadManifest();
  const resources: Resource[] = [
    {
      uri: MANIFEST_RESOURCE_URI,
      name: "manifest",
      title: "Wiki Manifest",
      description: "Full kbmap manifest for this wiki.",
      mimeType: "application/json",
    },
  ];

  for (const page of manifest.pages) {
    const fullPath = pagePath(page);
    const size = existsSync(fullPath) ? (await stat(fullPath)).size : undefined;
    resources.push({
      uri: pageResourceUri(page.slug),
      name: page.slug,
      title: page.slug,
      description: `${page.kind} page at ${page.path}`,
      mimeType: "text/markdown",
      size,
    });
  }

  return resources;
}

async function readResource(uri: string) {
  if (!manifest) manifest = await loadManifest();

  if (uri === MANIFEST_RESOURCE_URI) {
    return {
      contents: [
        {
          uri,
          mimeType: "application/json",
          text: JSON.stringify(manifest, null, 2),
        },
      ],
    };
  }

  const slug = slugFromPageResourceUri(uri);
  if (!slug) throw new Error(`Unsupported resource URI: ${uri}`);
  const entry = manifest.pages.find((p) => p.slug === slug);
  if (!entry) throw new Error(`Page resource not found: ${slug}`);
  const fullPath = pagePath(entry);
  if (!existsSync(fullPath)) throw new Error(`Page file not found: ${entry.path}`);
  return {
    contents: [
      {
        uri,
        mimeType: "text/markdown",
        text: await readFile(fullPath, "utf8"),
      },
    ],
  };
}

// ---- Tool handlers ---------------------------------------------------------

const tools = [
  {
    name: "get_page",
    description: "Fetch a wiki page (frontmatter + markdown body) by its slug.",
    inputSchema: {
      type: "object",
      properties: {
        slug: {
          type: "string",
          description:
            "Globally-unique page slug, e.g. 'enrollee-app/feature/enrollee-login'.",
        },
      },
      required: ["slug"],
    },
  },
  {
    name: "search_wiki",
    description:
      "Full-text search across the wiki. Optional filters by kind (component/feature/action/...) and audience (dev/user/agent).",
    inputSchema: {
      type: "object",
      properties: {
        query: { type: "string", description: "Search text." },
        kind: {
          type: "string",
          description: "Optional: restrict to a single kind.",
        },
        audience: {
          type: "string",
          description: "Optional: restrict to pages tagged for this audience.",
        },
      },
      required: ["query"],
    },
  },
  {
    name: "list_by_kind",
    description: "List every page of a given kind.",
    inputSchema: {
      type: "object",
      properties: {
        kind: {
          type: "string",
          description: "One of: component, feature, workflow, integration, decision, glossary, architecture, query-result, action.",
        },
      },
      required: ["kind"],
    },
  },
  {
    name: "get_feature",
    description:
      "Get a feature page plus its linked action contracts (resolved). Most efficient way to answer 'what is this feature and what can the agent dispatch for it?'",
    inputSchema: {
      type: "object",
      properties: { slug: { type: "string" } },
      required: ["slug"],
    },
  },
  {
    name: "get_component",
    description: "Get a component page plus its dependencies and dependents.",
    inputSchema: {
      type: "object",
      properties: { slug: { type: "string" } },
      required: ["slug"],
    },
  },
  {
    name: "get_workflow",
    description: "Get a workflow page plus its linked features.",
    inputSchema: {
      type: "object",
      properties: { slug: { type: "string" } },
      required: ["slug"],
    },
  },
  {
    name: "describe_action",
    description:
      "Describe an action's contract — endpoint, auth, side_effects, confirmation_required. NEVER executes the action; that's the write-side app-actions-mcp's job.",
    inputSchema: {
      type: "object",
      properties: { slug: { type: "string" } },
      required: ["slug"],
    },
  },
  {
    name: "recent_changes",
    description: "Pages whose last_updated is on or after the given ISO date.",
    inputSchema: {
      type: "object",
      properties: {
        since: {
          type: "string",
          description: "ISO date YYYY-MM-DD.",
        },
      },
      required: ["since"],
    },
  },
  {
    name: "get_manifest",
    description: "Return the full wiki manifest. Useful for clients that want to index the entire wiki at once.",
    inputSchema: { type: "object", properties: {}, required: [] },
  },
  {
    name: "graph_neighbors",
    description:
      "Return a graph node plus neighboring nodes, evidence-backed edges, and chunks from generated graph artifacts. Accepts a wiki slug or graph node id.",
    inputSchema: {
      type: "object",
      properties: {
        slug: {
          type: "string",
          description:
            "Wiki slug or graph node id, e.g. 'enrollee-app/component/navigation' or 'wiki:enrollee-app/component/navigation'.",
        },
        depth: {
          type: "number",
          description: "Traversal depth. Defaults to 1. Maximum is 3.",
        },
        edge_types: {
          type: "array",
          items: { type: "string" },
          description: "Optional edge type filter, e.g. ['LINKS_TO', 'PAGE_DESCRIBES_FILE'].",
        },
      },
      required: ["slug"],
    },
  },
  {
    name: "retrieve_context",
    description:
      "Retrieve ranked, cited context for a question using exact graph/chunk matching plus graph expansion. Supports wiki-first, code-first, qa-investigation, and cross-project modes.",
    inputSchema: {
      type: "object",
      properties: {
        query: {
          type: "string",
          description: "Natural-language question or investigation goal.",
        },
        mode: {
          type: "string",
          enum: ["wiki-first", "code-first", "qa-investigation", "cross-project"],
          description: "Retrieval strategy. Defaults to wiki-first.",
        },
        project_slug: {
          type: "string",
          description: "Optional project slug restriction.",
        },
        scope: {
          type: "object",
          properties: {
            slugs: {
              type: "array",
              items: { type: "string" },
              description: "Optional seed wiki slugs or graph node ids.",
            },
            kinds: {
              type: "array",
              items: { type: "string" },
              description: "Optional wiki kind/type filters.",
            },
            edge_types: {
              type: "array",
              items: { type: "string" },
              description: "Optional graph edge type filter.",
            },
          },
        },
        limits: {
          type: "object",
          properties: {
            evidence: {
              type: "number",
              description: "Maximum ranked evidence items. Default 10, maximum 30.",
            },
            graph_depth: {
              type: "number",
              description: "Graph traversal depth. Default depends on mode, maximum 3.",
            },
            chunks: {
              type: "number",
              description: "Maximum seed chunks considered. Default 8, maximum 20.",
            },
          },
        },
      },
      required: ["query"],
    },
  },
];

async function handleTool(name: string, args: Record<string, unknown>): Promise<unknown> {
  manifest = await loadManifest();

  switch (name) {
    case "get_page": {
      const slug = String(args.slug ?? "");
      const page = await readPageBySlug(slug);
      if (!page) throw new Error(`Page not found: ${slug}`);
      return page;
    }
    case "search_wiki": {
      const query = String(args.query ?? "");
      const kindF = args.kind ? String(args.kind) : undefined;
      const audF = args.audience ? String(args.audience) : undefined;
      return await fullTextSearch(query, kindF, audF);
    }
    case "list_by_kind": {
      const kind = String(args.kind ?? "");
      return manifest.pages.filter((p) => p.kind === kind);
    }
    case "get_feature": {
      const slug = String(args.slug ?? "");
      const page = await readPageBySlug(slug);
      if (!page || page.kind !== "feature") {
        throw new Error(`Feature not found: ${slug}`);
      }
      const actionSlugs = (page.frontmatter.actions as string[] | undefined) ?? [];
      const actions: ParsedPage[] = [];
      for (const aSlug of actionSlugs) {
        const a = await readPageBySlug(aSlug);
        if (a) actions.push(a);
      }
      return { feature: page, actions };
    }
    case "get_component": {
      const slug = String(args.slug ?? "");
      const page = await readPageBySlug(slug);
      if (!page || page.kind !== "component") {
        throw new Error(`Component not found: ${slug}`);
      }
      const entry = manifest.pages.find((p) => p.slug === slug);
      return {
        component: page,
        depends_on: (entry?.frontmatter_excerpt?.depends_on as string[]) ?? entry?.links_out ?? [],
        depended_on_by: entry?.links_in ?? [],
      };
    }
    case "get_workflow": {
      const slug = String(args.slug ?? "");
      const page = await readPageBySlug(slug);
      if (!page || page.kind !== "workflow") {
        throw new Error(`Workflow not found: ${slug}`);
      }
      const featSlugs = (page.frontmatter.features as string[] | undefined) ?? [];
      const features: ParsedPage[] = [];
      for (const fSlug of featSlugs) {
        const f = await readPageBySlug(fSlug);
        if (f) features.push(f);
      }
      return { workflow: page, features };
    }
    case "describe_action": {
      const slug = String(args.slug ?? "");
      const page = await readPageBySlug(slug);
      if (!page || page.kind !== "action") {
        throw new Error(`Action not found: ${slug}`);
      }
      const fm = page.frontmatter;
      return {
        slug: page.slug,
        endpoint: fm.endpoint,
        endpoint_kind: fm.endpoint_kind,
        auth_required: fm.auth_required,
        auth_via: fm.auth_via,
        confirmation_required: fm.confirmation_required,
        idempotent: fm.idempotent,
        side_effects: fm.side_effects ?? [],
        feature: fm.feature,
        notes_for_assistant: extractSection(page.body, "Notes for the assistant"),
        full_page: page,
      };
    }
    case "recent_changes": {
      const since = String(args.since ?? "");
      return manifest.pages.filter((p) => p.last_updated >= since);
    }
    case "get_manifest": {
      return manifest;
    }
    case "graph_neighbors": {
      if (!graphIndex || !graphIndex.available) {
        throw new Error(
          graphIndex?.warning ??
            `Graph artifacts are unavailable. Run the kbmap graph exporter and set GRAPH_PATH if needed.`
        );
      }
      const slug = String(args.slug ?? "");
      const depth = Number.isFinite(Number(args.depth)) ? Number(args.depth) : 1;
      const edgeTypes = Array.isArray(args.edge_types)
        ? args.edge_types.map((value) => String(value))
        : undefined;
      return getGraphNeighborhood(graphIndex, slug, depth, edgeTypes);
    }
    case "retrieve_context": {
      return retrieveContext(graphIndex, {
        query: String(args.query ?? ""),
        mode: typeof args.mode === "string" ? args.mode : undefined,
        project_slug: typeof args.project_slug === "string" ? args.project_slug : undefined,
        scope: isRecord(args.scope)
          ? {
              slugs: Array.isArray(args.scope.slugs) ? args.scope.slugs.map((value) => String(value)) : undefined,
              kinds: Array.isArray(args.scope.kinds) ? args.scope.kinds.map((value) => String(value)) : undefined,
              edge_types: Array.isArray(args.scope.edge_types) ? args.scope.edge_types.map((value) => String(value)) : undefined,
            }
          : undefined,
        limits: isRecord(args.limits)
          ? {
              evidence: typeof args.limits.evidence === "number" ? args.limits.evidence : undefined,
              graph_depth: typeof args.limits.graph_depth === "number" ? args.limits.graph_depth : undefined,
              chunks: typeof args.limits.chunks === "number" ? args.limits.chunks : undefined,
            }
          : undefined,
      });
    }
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

// Pull a single ## section's body out of a page's markdown.
function extractSection(body: string, heading: string): string | null {
  const re = new RegExp(`^## ${heading}\\s*$`, "m");
  const m = body.match(re);
  if (!m || m.index === undefined) return null;
  const start = m.index + m[0].length;
  const rest = body.slice(start);
  const next = rest.match(/^## /m);
  const end = next?.index ?? rest.length;
  return rest.slice(0, end).trim();
}

// ---- MCP server wiring ------------------------------------------------------

const server = new Server(
  {
    name: "wiki-mcp",
    version: "0.1.0",
  },
  {
    capabilities: {
      resources: {},
      tools: {},
    },
  }
);

server.setRequestHandler(ListResourcesRequestSchema, async () => ({
  resources: await listResources(),
}));

server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  try {
    return await readResource(request.params.uri);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    throw new Error(msg);
  }
});

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools,
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  try {
    const result = await handleTool(name, args ?? {});
    return {
      content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
    };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return {
      content: [{ type: "text", text: `error: ${msg}` }],
      isError: true,
    };
  }
});

// ---- Startup ----------------------------------------------------------------

async function main() {
  // Load manifest once at startup to fail fast on version mismatch.
  manifest = await loadManifest();
  graphIndex = await loadGraphIndex(GRAPH_PATH);
  console.error(
    `[wiki-mcp] serving wiki at ${WIKI_PATH} ` +
      `(project_slug=${manifest.project_slug}, ${manifest.page_count} pages, ` +
      `manifest_version=${manifest.manifest_version})`
  );
  if (graphIndex.available) {
    console.error(
      `[wiki-mcp] loaded graph artifacts at ${GRAPH_PATH} ` +
        `(${graphIndex.nodes.length} nodes, ${graphIndex.edges.length} edges, ` +
        `${graphIndex.chunks.length} chunks)`
    );
  } else if (graphIndex.warning) {
    console.error(graphIndex.warning);
  }

  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error("[wiki-mcp] startup failed:", err);
  process.exit(1);
});
