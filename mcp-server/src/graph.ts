import { readFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join, resolve } from "node:path";

const GRAPH_SCHEMA_VERSION_SUPPORTED = 1;
const ARTIFACT_SCHEMA_VERSION_SUPPORTED = 1;

export interface GraphNode {
  schema_version: number;
  id: string;
  type: string;
  project_slug: string;
  label: string;
  source: Record<string, unknown>;
  properties: Record<string, unknown>;
  aliases?: string[];
}

export interface GraphEdge {
  schema_version: number;
  id: string;
  type: string;
  source: string;
  target: string;
  directed: boolean;
  confidence: string;
  evidence: Array<Record<string, unknown>>;
  properties: Record<string, unknown>;
}

export interface GraphChunk {
  schema_version: number;
  id: string;
  source_node: string;
  project_slug: string;
  chunk_index: number;
  text: string;
  source: Record<string, unknown>;
  properties: Record<string, unknown>;
}

export interface GraphExportReport {
  artifact_schema_version: number;
  graph_schema_version: number;
  generated_at: string;
  project_slug: string;
  artifacts?: Record<string, unknown>;
  validation?: {
    status?: string;
    errors?: unknown[];
    warnings?: unknown[];
  };
}

export interface GraphIndex {
  available: boolean;
  path: string;
  warning?: string;
  report?: GraphExportReport;
  nodes: GraphNode[];
  edges: GraphEdge[];
  chunks: GraphChunk[];
  nodesById: Map<string, GraphNode>;
  edgesBySource: Map<string, GraphEdge[]>;
  edgesByTarget: Map<string, GraphEdge[]>;
  chunksBySourceNode: Map<string, GraphChunk[]>;
}

export interface GraphNeighborhood {
  root: GraphNode;
  depth: number;
  edge_types: string[] | null;
  nodes: GraphNode[];
  edges: GraphEdge[];
  chunks: GraphChunk[];
}

export function resolveGraphPath(wikiPath: string): string {
  return process.env.GRAPH_PATH ? resolve(process.env.GRAPH_PATH) : resolve(wikiPath, "..", "graph");
}

export async function loadGraphIndex(graphPath: string): Promise<GraphIndex> {
  const nodesPath = join(graphPath, "nodes.jsonl");
  const edgesPath = join(graphPath, "edges.jsonl");
  const chunksPath = join(graphPath, "chunks.jsonl");
  const reportPath = join(graphPath, "export-report.json");

  const required = [nodesPath, edgesPath, chunksPath, reportPath];
  const missing = required.filter((path) => !existsSync(path));
  if (missing.length > 0) {
    return {
      available: false,
      path: graphPath,
      warning:
        `[wiki-mcp] graph artifacts unavailable at ${graphPath}; ` +
        `missing ${missing.map((path) => path.split("/").pop()).join(", ")}. ` +
        `Graph tools will run in degraded mode until graph export is generated.`,
      nodes: [],
      edges: [],
      chunks: [],
      nodesById: new Map(),
      edgesBySource: new Map(),
      edgesByTarget: new Map(),
      chunksBySourceNode: new Map(),
    };
  }

  const report = JSON.parse(await readFile(reportPath, "utf8")) as GraphExportReport;
  validateReport(report);

  const nodes = await readJsonl<GraphNode>(nodesPath);
  const edges = await readJsonl<GraphEdge>(edgesPath);
  const chunks = await readJsonl<GraphChunk>(chunksPath);
  validateRecords(nodes, edges, chunks);

  return buildGraphIndex(graphPath, report, nodes, edges, chunks);
}

export function getGraphNode(index: GraphIndex, id: string): GraphNode | null {
  return index.nodesById.get(id) ?? null;
}

export function getGraphEdges(index: GraphIndex, id: string): GraphEdge[] {
  return [
    ...(index.edgesBySource.get(id) ?? []),
    ...(index.edgesByTarget.get(id) ?? []),
  ].sort(compareEdges);
}

export function getGraphChunks(index: GraphIndex, id: string): GraphChunk[] {
  return [...(index.chunksBySourceNode.get(id) ?? [])].sort((a, b) => {
    return a.chunk_index - b.chunk_index || a.id.localeCompare(b.id);
  });
}

export function graphNodeIdFromSlugOrId(slugOrId: string): string {
  if (
    slugOrId.startsWith("wiki:") ||
    slugOrId.startsWith("project:") ||
    slugOrId.startsWith("file:") ||
    slugOrId.startsWith("symbol:") ||
    slugOrId.startsWith("endpoint:") ||
    slugOrId.startsWith("route:") ||
    slugOrId.startsWith("table:") ||
    slugOrId.startsWith("memory:")
  ) {
    return slugOrId;
  }
  return `wiki:${slugOrId}`;
}

export function getGraphNeighborhood(
  index: GraphIndex,
  slugOrId: string,
  depth: number,
  edgeTypes?: string[]
): GraphNeighborhood {
  const rootId = graphNodeIdFromSlugOrId(slugOrId);
  const root = getGraphNode(index, rootId);
  if (!root) throw new Error(`Graph node not found: ${slugOrId}`);

  const boundedDepth = Math.max(0, Math.min(depth, 3));
  const typeFilter = edgeTypes && edgeTypes.length > 0 ? new Set(edgeTypes) : null;
  const seenNodes = new Set<string>([root.id]);
  const seenEdges = new Set<string>();
  let frontier = new Set<string>([root.id]);

  for (let currentDepth = 0; currentDepth < boundedDepth; currentDepth += 1) {
    const next = new Set<string>();
    for (const nodeId of frontier) {
      const edges = getGraphEdges(index, nodeId).filter((edge) => {
        return !typeFilter || typeFilter.has(edge.type);
      });
      for (const edge of edges) {
        seenEdges.add(edge.id);
        if (!seenNodes.has(edge.source)) {
          seenNodes.add(edge.source);
          next.add(edge.source);
        }
        if (!seenNodes.has(edge.target)) {
          seenNodes.add(edge.target);
          next.add(edge.target);
        }
      }
    }
    frontier = next;
    if (frontier.size === 0) break;
  }

  const nodes = [...seenNodes]
    .map((id) => index.nodesById.get(id))
    .filter((node): node is GraphNode => Boolean(node))
    .sort((a, b) => a.id.localeCompare(b.id));
  const edges = [...seenEdges]
    .map((id) => index.edges.find((edge) => edge.id === id))
    .filter((edge): edge is GraphEdge => Boolean(edge))
    .sort(compareEdges);
  const chunks = nodes.flatMap((node) => getGraphChunks(index, node.id));

  return {
    root,
    depth: boundedDepth,
    edge_types: typeFilter ? [...typeFilter].sort() : null,
    nodes,
    edges,
    chunks,
  };
}

async function readJsonl<T>(path: string): Promise<T[]> {
  const raw = await readFile(path, "utf8");
  return raw
    .split(/\r?\n/)
    .filter((line) => line.trim() !== "")
    .map((line) => JSON.parse(line) as T);
}

function validateReport(report: GraphExportReport) {
  if (report.artifact_schema_version > ARTIFACT_SCHEMA_VERSION_SUPPORTED) {
    throw new Error(
      `[wiki-mcp] artifact_schema_version=${report.artifact_schema_version} is newer than ` +
        `ARTIFACT_SCHEMA_VERSION_SUPPORTED=${ARTIFACT_SCHEMA_VERSION_SUPPORTED}. ` +
        `Regenerate graph artifacts with a compatible exporter or upgrade wiki-mcp.`
    );
  }
  if (report.graph_schema_version > GRAPH_SCHEMA_VERSION_SUPPORTED) {
    throw new Error(
      `[wiki-mcp] graph_schema_version=${report.graph_schema_version} is newer than ` +
        `GRAPH_SCHEMA_VERSION_SUPPORTED=${GRAPH_SCHEMA_VERSION_SUPPORTED}. ` +
        `Regenerate graph artifacts with a compatible exporter or upgrade wiki-mcp.`
    );
  }
  if (report.validation?.status && report.validation.status !== "passed") {
    throw new Error(
      `[wiki-mcp] graph export report validation status is ${report.validation.status}; ` +
        `refusing to load invalid graph artifacts.`
    );
  }
}

function validateRecords(nodes: GraphNode[], edges: GraphEdge[], chunks: GraphChunk[]) {
  const nodeIds = new Set<string>();
  for (const node of nodes) {
    if (node.schema_version > GRAPH_SCHEMA_VERSION_SUPPORTED) {
      throw new Error(`[wiki-mcp] node ${node.id} uses unsupported schema_version=${node.schema_version}.`);
    }
    if (!node.id || !node.type || !node.source || !node.properties) {
      throw new Error(`[wiki-mcp] graph node is missing required fields: ${JSON.stringify(node)}`);
    }
    if (nodeIds.has(node.id)) throw new Error(`[wiki-mcp] duplicate graph node id: ${node.id}`);
    nodeIds.add(node.id);
  }

  const edgeIds = new Set<string>();
  for (const edge of edges) {
    if (edge.schema_version > GRAPH_SCHEMA_VERSION_SUPPORTED) {
      throw new Error(`[wiki-mcp] edge ${edge.id} uses unsupported schema_version=${edge.schema_version}.`);
    }
    if (!edge.id || !edge.source || !edge.target || !edge.type || !edge.confidence) {
      throw new Error(`[wiki-mcp] graph edge is missing required fields: ${JSON.stringify(edge)}`);
    }
    if (!Array.isArray(edge.evidence) || edge.evidence.length === 0) {
      throw new Error(`[wiki-mcp] graph edge has no evidence: ${edge.id}`);
    }
    if (!nodeIds.has(edge.source)) throw new Error(`[wiki-mcp] graph edge missing source node: ${edge.id}`);
    if (!nodeIds.has(edge.target)) throw new Error(`[wiki-mcp] graph edge missing target node: ${edge.id}`);
    if (edgeIds.has(edge.id)) throw new Error(`[wiki-mcp] duplicate graph edge id: ${edge.id}`);
    edgeIds.add(edge.id);
  }

  const chunkIds = new Set<string>();
  for (const chunk of chunks) {
    if (chunk.schema_version > ARTIFACT_SCHEMA_VERSION_SUPPORTED) {
      throw new Error(`[wiki-mcp] chunk ${chunk.id} uses unsupported schema_version=${chunk.schema_version}.`);
    }
    if (!chunk.id || !chunk.source_node || !chunk.source || !chunk.properties) {
      throw new Error(`[wiki-mcp] graph chunk is missing required fields: ${JSON.stringify(chunk)}`);
    }
    if (!nodeIds.has(chunk.source_node)) {
      throw new Error(`[wiki-mcp] graph chunk missing source node: ${chunk.id}`);
    }
    if (chunkIds.has(chunk.id)) throw new Error(`[wiki-mcp] duplicate graph chunk id: ${chunk.id}`);
    chunkIds.add(chunk.id);
  }
}

function buildGraphIndex(
  graphPath: string,
  report: GraphExportReport,
  nodes: GraphNode[],
  edges: GraphEdge[],
  chunks: GraphChunk[]
): GraphIndex {
  const nodesById = new Map(nodes.map((node) => [node.id, node]));
  const edgesBySource = new Map<string, GraphEdge[]>();
  const edgesByTarget = new Map<string, GraphEdge[]>();
  const chunksBySourceNode = new Map<string, GraphChunk[]>();

  for (const edge of edges) {
    pushMap(edgesBySource, edge.source, edge);
    pushMap(edgesByTarget, edge.target, edge);
  }
  for (const chunk of chunks) {
    pushMap(chunksBySourceNode, chunk.source_node, chunk);
  }

  return {
    available: true,
    path: graphPath,
    report,
    nodes,
    edges,
    chunks,
    nodesById,
    edgesBySource,
    edgesByTarget,
    chunksBySourceNode,
  };
}

function pushMap<T>(map: Map<string, T[]>, key: string, value: T) {
  const existing = map.get(key);
  if (existing) existing.push(value);
  else map.set(key, [value]);
}

function compareEdges(a: GraphEdge, b: GraphEdge): number {
  return (
    a.source.localeCompare(b.source) ||
    a.type.localeCompare(b.type) ||
    a.target.localeCompare(b.target) ||
    a.id.localeCompare(b.id)
  );
}
