import {
  GraphChunk,
  GraphEdge,
  GraphIndex,
  GraphNode,
  getGraphChunks,
  getGraphEdges,
  getGraphNeighborhood,
  graphNodeIdFromSlugOrId,
} from "./graph.js";

const RETRIEVE_CONTEXT_SCHEMA_VERSION = 1;
const VALID_MODES = new Set(["wiki-first", "code-first", "qa-investigation", "cross-project"]);
type RetrieveMode = "wiki-first" | "code-first" | "qa-investigation" | "cross-project";
type RetrievalConfidence = "high" | "medium" | "low" | "insufficient";

export interface RetrieveContextInput {
  query: string;
  mode?: RetrieveMode | string;
  project_slug?: string;
  scope?: {
    slugs?: string[];
    kinds?: string[];
    edge_types?: string[];
  };
  limits?: {
    evidence?: number;
    graph_depth?: number;
    chunks?: number;
  };
}

interface EvidenceScore {
  relevance: number;
  authority: number;
  recency: number;
  graph_support: number;
}

interface Citation {
  path?: unknown;
  slug?: unknown;
  selector?: unknown;
  node_id?: string;
}

interface RankedEvidence {
  id: string;
  rank: number;
  source_type: string;
  node_id: string;
  title: string;
  snippet: string;
  citation: Citation;
  score: EvidenceScore;
  confidence: RetrievalConfidence;
  supports: string[];
  graph_context: {
    neighbors: string[];
    edge_ids: string[];
  };
}

interface GraphPath {
  id: string;
  from: string;
  to: string;
  edges: Array<{
    id: string;
    type: string;
    confidence: string;
  }>;
  confidence: RetrievalConfidence;
  explanation: string;
}

interface MissingEvidence {
  kind: string;
  severity: "low" | "medium" | "high";
  message: string;
  suggested_action: string;
  related_nodes: string[];
}

export interface RetrieveContextResult {
  schema_version: number;
  query: string;
  mode: RetrieveMode;
  confidence: RetrievalConfidence;
  answer_context: {
    summary: string;
    recommended_next_step: string;
  };
  ranked_evidence: RankedEvidence[];
  graph_paths: GraphPath[];
  citations: Citation[];
  missing_evidence: MissingEvidence[];
  retrieval_trace: {
    strategies_used: string[];
    seed_nodes: string[];
    expanded_nodes: string[];
    degraded: boolean;
    warnings: string[];
  };
}

interface Candidate {
  node: GraphNode;
  chunk?: GraphChunk;
  relevance: number;
  source: "chunk" | "node" | "scope";
}

interface QueryTerms {
  raw: string;
  tokens: string[];
  phrases: string[];
}

export function retrieveContext(index: GraphIndex | null, input: RetrieveContextInput): RetrieveContextResult {
  const query = normalizeQuery(input.query);
  const mode = normalizeMode(input.mode);
  const limits = normalizeLimits(input.limits, mode);
  const missing: MissingEvidence[] = [];
  const warnings: string[] = [];

  if (!index || !index.available) {
    const message = index?.warning ?? "Graph artifacts are unavailable.";
    return {
      schema_version: RETRIEVE_CONTEXT_SCHEMA_VERSION,
      query,
      mode,
      confidence: "insufficient",
      answer_context: {
        summary: "No graph-backed context could be retrieved because graph artifacts are unavailable.",
        recommended_next_step: "Run the kbmap graph exporter and set GRAPH_PATH if the artifacts are outside the default wiki sibling directory.",
      },
      ranked_evidence: [],
      graph_paths: [],
      citations: [],
      missing_evidence: [
        {
          kind: "graph_unavailable",
          severity: "high",
          message,
          suggested_action: "Generate graph artifacts before using retrieve_context for grounded QA.",
          related_nodes: [],
        },
      ],
      retrieval_trace: {
        strategies_used: ["exact"],
        seed_nodes: [],
        expanded_nodes: [],
        degraded: true,
        warnings: [message],
      },
    };
  }

  const terms = buildQueryTerms(query);
  const scopedKinds = new Set(input.scope?.kinds ?? []);
  const projectSlug = input.project_slug;
  const candidates = new Map<string, Candidate>();

  for (const slug of input.scope?.slugs ?? []) {
    const node = index.nodesById.get(graphNodeIdFromSlugOrId(slug));
    if (node && matchesProjectAndKind(node, projectSlug, scopedKinds)) {
      candidates.set(node.id, { node, relevance: 1, source: "scope" });
    }
  }

  for (const chunk of index.chunks) {
    if (projectSlug && chunk.project_slug !== projectSlug) continue;
    const node = index.nodesById.get(chunk.source_node);
    if (!node || !matchesProjectAndKind(node, projectSlug, scopedKinds)) continue;
    const relevance = scoreCandidate(terms, node, chunk.text, mode);
    if (relevance <= 0) continue;
    const existing = candidates.get(node.id);
    if (!existing || relevance > existing.relevance) {
      candidates.set(node.id, { node, chunk, relevance, source: "chunk" });
    }
  }

  for (const node of index.nodes) {
    if (!matchesProjectAndKind(node, projectSlug, scopedKinds)) continue;
    const relevance = scoreCandidate(terms, node, searchableNodeText(node), mode);
    if (relevance <= 0) continue;
    const existing = candidates.get(node.id);
    if (!existing || relevance > existing.relevance) {
      candidates.set(node.id, { node, relevance, source: "node" });
    }
  }

  const edgeTypes = input.scope?.edge_types?.length
    ? input.scope.edge_types
    : preferredEdgesForMode(mode);
  const rankedSeeds = [...candidates.values()].sort(compareCandidates).slice(0, Math.max(limits.evidence, limits.chunks));
  const expandedNodeIds = new Set<string>();
  const traversedEdges = new Map<string, GraphEdge>();

  for (const candidate of rankedSeeds.slice(0, limits.evidence)) {
    try {
      const neighborhood = getGraphNeighborhood(index, candidate.node.id, limits.graph_depth, edgeTypes);
      for (const node of neighborhood.nodes) expandedNodeIds.add(node.id);
      for (const edge of neighborhood.edges) traversedEdges.set(edge.id, edge);
    } catch (error) {
      warnings.push(error instanceof Error ? error.message : String(error));
    }
  }

  const graphEdges = [...traversedEdges.values()];
  const evidence = rankedSeeds
    .slice(0, limits.evidence)
    .map((candidate, indexInRank) => makeEvidence(candidate, indexInRank + 1, graphEdges, mode));
  const graphPaths = makeGraphPaths(rankedSeeds, graphEdges, limits.evidence);
  const citations = dedupeCitations(evidence.map((entry) => entry.citation));

  if (evidence.length === 0) {
    missing.push({
      kind: "missing_wiki_intent",
      severity: mode === "code-first" ? "medium" : "high",
      message: "No exact graph chunk or node evidence matched the query.",
      suggested_action: "Broaden the query, add scoped slugs, or generate semantic retrieval indexes behind this contract.",
      related_nodes: [],
    });
  }

  if (mode === "qa-investigation" && evidence.some((entry) => entry.source_type === "wiki")) {
    const hasBridge = graphEdges.some((edge) => edge.type.startsWith("PAGE_DESCRIBES") || edge.type.includes("ENDPOINT") || edge.type.includes("ROUTE"));
    if (!hasBridge) {
      missing.push({
        kind: "missing_code_bridge",
        severity: "medium",
        message: "Wiki evidence was found, but no code bridge/path was retrieved within the configured graph depth.",
        suggested_action: "Run code graph extraction and review source_path frontmatter for the cited wiki pages.",
        related_nodes: evidence.map((entry) => entry.node_id),
      });
    }
  }

  warnings.push("Semantic retrieval is not enabled in this MVP; exact graph retrieval was used.");
  const confidence = confidenceFor(evidence, missing, graphPaths);

  return {
    schema_version: RETRIEVE_CONTEXT_SCHEMA_VERSION,
    query,
    mode,
    confidence,
    answer_context: {
      summary: summaryFor(evidence, graphPaths, missing),
      recommended_next_step: nextStepFor(confidence, missing),
    },
    ranked_evidence: evidence,
    graph_paths: graphPaths,
    citations,
    missing_evidence: missing,
    retrieval_trace: {
      strategies_used: ["exact", "graph"],
      seed_nodes: rankedSeeds.map((candidate) => candidate.node.id),
      expanded_nodes: [...expandedNodeIds].sort(),
      degraded: warnings.length > 0,
      warnings,
    },
  };
}

function normalizeQuery(query: string): string {
  if (typeof query !== "string" || !query.trim()) throw new Error("retrieve_context requires a non-empty query.");
  return query.trim();
}

function normalizeMode(mode: RetrieveContextInput["mode"]): RetrieveMode {
  if (typeof mode === "string" && VALID_MODES.has(mode)) return mode as RetrieveMode;
  return "wiki-first";
}

function normalizeLimits(limits: RetrieveContextInput["limits"], mode: RetrieveMode) {
  return {
    evidence: clampNumber(limits?.evidence, 10, 1, 30),
    graph_depth: clampNumber(limits?.graph_depth, defaultDepthForMode(mode), 0, 3),
    chunks: clampNumber(limits?.chunks, 8, 1, 20),
  };
}

function defaultDepthForMode(mode: RetrieveMode): number {
  return mode === "qa-investigation" ? 3 : 2;
}

function clampNumber(value: unknown, fallback: number, min: number, max: number): number {
  const number = Number(value);
  if (!Number.isFinite(number)) return fallback;
  return Math.max(min, Math.min(Math.floor(number), max));
}

function matchesProjectAndKind(node: GraphNode, projectSlug: string | undefined, kinds: Set<string>): boolean {
  if (projectSlug && node.project_slug !== projectSlug) return false;
  if (kinds.size === 0) return true;
  const kind = typeof node.properties.kind === "string" ? node.properties.kind : node.type.toLowerCase();
  return kinds.has(kind) || kinds.has(node.type);
}

function tokenize(text: string): string[] {
  const stop = new Set(["the", "and", "for", "with", "what", "which", "how", "does", "are", "is", "to", "a", "an", "of", "in", "on", "should", "when"]);
  return [...new Set(text.toLowerCase().split(/[^a-z0-9_/-]+/).filter((token) => token.length > 2 && !stop.has(token)))];
}

function buildQueryTerms(query: string): QueryTerms {
  const raw = query.toLowerCase();
  const tokens = tokenize(query);
  return {
    raw,
    tokens,
    phrases: buildPhrases(tokens),
  };
}

function buildPhrases(tokens: string[]): string[] {
  const phrases = [];
  for (let size = 3; size >= 2; size -= 1) {
    for (let index = 0; index <= tokens.length - size; index += 1) {
      const phraseTokens = tokens.slice(index, index + size);
      if (phraseTokens.some((token) => token.includes("/"))) continue;
      phrases.push(phraseTokens.join(" "));
      phrases.push(phraseTokens.join("-"));
    }
  }
  return [...new Set(phrases)];
}

function scoreText(tokens: string[], text: string): number {
  if (tokens.length === 0) return 0;
  const haystack = text.toLowerCase();
  let hits = 0;
  for (const token of tokens) {
    if (haystack.includes(token)) hits += 1;
  }
  return hits / tokens.length;
}

function scoreCandidate(terms: QueryTerms, node: GraphNode, bodyText: string, mode: RetrieveMode): number {
  if (terms.tokens.length === 0) return 0;

  const metadata = metadataTextFor(node);
  const bodyScore = scoreText(terms.tokens, bodyText);
  const slugScore = scoreText(terms.tokens, slugTextFor(node));
  const labelScore = scoreText(terms.tokens, node.label);
  const tagScore = scoreText(terms.tokens, tagsTextFor(node));
  const sourceScore = scoreText(terms.tokens, sourcePathTextFor(node));
  const focusText = `${slugTextFor(node)} ${node.label} ${tagsTextFor(node)}`;
  const slugLabelText = `${slugTextFor(node)} ${node.label}`;
  const phraseScore = phraseMatchScore(terms.phrases, focusText);

  let score =
    bodyScore * 0.55 +
    slugScore * 0.35 +
    labelScore * 0.35 +
    tagScore * 0.15 +
    sourceScore * 0.15 +
    phraseScore * 0.4;

  score += kindRankAdjustment(node, mode, slugScore, labelScore, tagScore);
  score += exactFocusBoost(terms.phrases, focusText);
  score += exactSlugLabelBoost(terms.phrases, slugLabelText);

  if (metadataIncludesAny(metadata, terms.tokens)) score += 0.05;
  if (node.id.startsWith("file:") && (slugScore > 0.45 || sourceScore > 0.45)) score += 0.08;

  return Math.max(0, round(score));
}

function metadataTextFor(node: GraphNode): string {
  return [
    node.id,
    node.type,
    node.label,
    slugTextFor(node),
    tagsTextFor(node),
    sourcePathTextFor(node),
    ...(node.aliases ?? []),
  ].join(" ").toLowerCase();
}

function slugTextFor(node: GraphNode): string {
  const slug = typeof node.properties.slug === "string" ? node.properties.slug : node.id;
  return slug.replace(/^wiki:/, "").replace(/^file:[^:]+:/, "").replace(/[/-]+/g, " ");
}

function tagsTextFor(node: GraphNode): string {
  const tags = node.properties.tags;
  return Array.isArray(tags) ? tags.map((tag) => String(tag)).join(" ") : "";
}

function sourcePathTextFor(node: GraphNode): string {
  const sourcePath = node.properties.source_path ?? node.properties.relative_path ?? node.source.path;
  return typeof sourcePath === "string" ? sourcePath.replace(/[/-]+/g, " ") : "";
}

function phraseMatchScore(phrases: string[], text: string): number {
  if (phrases.length === 0) return 0;
  const haystack = text.toLowerCase().replace(/[/-]+/g, " ");
  const hits = phrases.filter((phrase) => haystack.includes(phrase.replace(/-/g, " "))).length;
  return Math.min(1, hits / 2);
}

function exactFocusBoost(phrases: string[], text: string): number {
  if (phrases.length === 0) return 0;
  const haystack = text.toLowerCase().replace(/[/-]+/g, " ");
  if (phrases.some((phrase) => haystack.includes(phrase.replace(/-/g, " ")))) return 0.18;
  return 0;
}

function exactSlugLabelBoost(phrases: string[], text: string): number {
  if (phrases.length === 0) return 0;
  const haystack = text.toLowerCase().replace(/[/-]+/g, " ");
  if (phrases.some((phrase) => haystack.includes(phrase.replace(/-/g, " ")))) return 0.25;
  return 0;
}

function kindRankAdjustment(
  node: GraphNode,
  mode: RetrieveMode,
  slugScore: number,
  labelScore: number,
  tagScore: number
): number {
  const kind = typeof node.properties.kind === "string" ? node.properties.kind : node.type.toLowerCase();
  const focusedMatch = Math.max(slugScore, labelScore, tagScore);

  if (["schema", "mapping-log"].includes(kind)) return focusedMatch >= 0.75 ? -0.05 : -0.45;
  if (kind === "overview" && node.id.endsWith("/overview/index")) return focusedMatch >= 0.75 ? -0.05 : -0.35;
  if (kind === "overview" || kind === "query-result") return focusedMatch >= 0.75 ? 0 : -0.2;

  if (mode === "code-first" && node.id.startsWith("file:")) return 0.15;
  if (kind === "component") return 0.12;
  if (["feature", "workflow", "action", "integration", "decision", "architecture"].includes(kind)) return 0.08;
  return 0;
}

function metadataIncludesAny(metadata: string, tokens: string[]): boolean {
  return tokens.some((token) => metadata.includes(token));
}

function searchableNodeText(node: GraphNode): string {
  return [
    node.id,
    node.type,
    node.label,
    ...(node.aliases ?? []),
    JSON.stringify(node.source ?? {}),
    JSON.stringify(node.properties ?? {}),
  ].join(" ");
}

function compareCandidates(a: Candidate, b: Candidate): number {
  return b.relevance - a.relevance || authorityFor(b.node) - authorityFor(a.node) || a.node.id.localeCompare(b.node.id);
}

function preferredEdgesForMode(mode: RetrieveMode): string[] {
  switch (mode) {
    case "code-first":
      return ["DECLARES", "CALLS", "USES_ENDPOINT", "HANDLES_ROUTE", "CONFIGURES", "PAGE_DESCRIBES_FILE"];
    case "qa-investigation":
      return ["PAGE_DESCRIBES_FILE", "PAGE_DESCRIBES_SYMBOL", "USES_ENDPOINT", "HANDLES_ROUTE", "READS_TABLE", "WRITES_TABLE", "LINKS_TO"];
    case "cross-project":
      return ["OBSERVED_IN", "RELATED_TO", "LINKS_TO", "PAGE_DESCRIBES_FILE"];
    case "wiki-first":
    default:
      return ["LINKS_TO", "IMPLEMENTS", "PARTICIPATES_IN", "PAGE_DESCRIBES_FILE", "PAGE_DESCRIBES_SYMBOL"];
  }
}

function makeEvidence(candidate: Candidate, rank: number, graphEdges: GraphEdge[], mode: RetrieveMode): RankedEvidence {
  const relatedEdges = graphEdges.filter((edge) => edge.source === candidate.node.id || edge.target === candidate.node.id);
  const relatedNodes = relatedEdges.map((edge) => edge.source === candidate.node.id ? edge.target : edge.source);
  const score = {
    relevance: round(candidate.relevance),
    authority: round(authorityFor(candidate.node)),
    recency: 0.5,
    graph_support: round(Math.min(1, relatedEdges.length / 3)),
  };
  const sourceType = sourceTypeForNode(candidate.node);
  return {
    id: `ev:${String(rank).padStart(3, "0")}`,
    rank,
    source_type: sourceType,
    node_id: candidate.node.id,
    title: candidate.node.label,
    snippet: snippetFor(candidate),
    citation: citationFor(candidate),
    score,
    confidence: evidenceConfidence(candidate, relatedEdges),
    supports: supportsFor(candidate.node, mode),
    graph_context: {
      neighbors: [...new Set(relatedNodes)].sort(),
      edge_ids: relatedEdges.map((edge) => edge.id).sort(),
    },
  };
}

function snippetFor(candidate: Candidate): string {
  const text = candidate.chunk?.text ?? searchableNodeText(candidate.node);
  return text.replace(/\s+/g, " ").trim().slice(0, 420);
}

function citationFor(candidate: Candidate): Citation {
  const source = candidate.chunk?.source ?? candidate.node.source;
  return {
    path: source.path,
    slug: source.slug,
    selector: source.selector,
    node_id: candidate.node.id,
  };
}

function sourceTypeForNode(node: GraphNode): string {
  if (node.id.startsWith("wiki:")) return "wiki";
  if (node.id.startsWith("file:") || node.id.startsWith("symbol:") || node.id.startsWith("endpoint:") || node.id.startsWith("route:") || node.id.startsWith("table:")) {
    return "code";
  }
  return node.type.toLowerCase();
}

function supportsFor(node: GraphNode, mode: RetrieveMode): string[] {
  if (node.id.startsWith("wiki:")) return ["intended_behavior"];
  if (node.type === "Endpoint") return ["implementation", "endpoint"];
  if (node.type === "Route") return ["implementation", "route"];
  if (node.type === "DatabaseTable") return ["implementation", "data_model"];
  if (mode === "cross-project") return ["pattern"];
  return ["implementation"];
}

function evidenceConfidence(candidate: Candidate, edges: GraphEdge[]): RetrievalConfidence {
  if (candidate.relevance >= 0.8 && edges.some((edge) => edge.confidence === "high" || edge.confidence === "verified")) return "high";
  if (candidate.relevance >= 0.5) return "medium";
  return "low";
}

function makeGraphPaths(candidates: Candidate[], graphEdges: GraphEdge[], limit: number): GraphPath[] {
  const paths: GraphPath[] = [];
  let index = 1;
  for (const candidate of candidates.slice(0, limit)) {
    const edge = graphEdges.find((entry) => entry.source === candidate.node.id || entry.target === candidate.node.id);
    if (!edge) continue;
    const other = edge.source === candidate.node.id ? edge.target : edge.source;
    paths.push({
      id: `path:${String(index).padStart(3, "0")}`,
      from: candidate.node.id,
      to: other,
      edges: [{ id: edge.id, type: edge.type, confidence: edge.confidence }],
      confidence: graphPathConfidence(edge),
      explanation: `${candidate.node.id} connects to ${other} via ${edge.type}.`,
    });
    index += 1;
  }
  return paths;
}

function graphPathConfidence(edge: GraphEdge): RetrievalConfidence {
  if (edge.confidence === "verified" || edge.confidence === "high") return "high";
  if (edge.confidence === "medium") return "medium";
  return "low";
}

function dedupeCitations(citations: Citation[]): Citation[] {
  const seen = new Set<string>();
  const out: Citation[] = [];
  for (const citation of citations) {
    const key = JSON.stringify(citation);
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(citation);
  }
  return out;
}

function confidenceFor(evidence: RankedEvidence[], missing: MissingEvidence[], graphPaths: GraphPath[]): RetrievalConfidence {
  if (evidence.length === 0) return "insufficient";
  if (missing.some((entry) => entry.severity === "high")) return "low";
  if (evidence.some((entry) => entry.confidence === "high") && graphPaths.length > 0) return "high";
  if (evidence.some((entry) => entry.confidence === "medium" || entry.confidence === "high")) return "medium";
  return "low";
}

function summaryFor(evidence: RankedEvidence[], graphPaths: GraphPath[], missing: MissingEvidence[]): string {
  if (evidence.length === 0) return "No grounded evidence matched the query.";
  const gapText = missing.length > 0 ? ` ${missing.length} evidence gap(s) were identified.` : "";
  return `Retrieved ${evidence.length} ranked evidence item(s) and ${graphPaths.length} graph path(s).${gapText}`;
}

function nextStepFor(confidence: RetrievalConfidence, missing: MissingEvidence[]): string {
  if (missing.length > 0) return missing[0].suggested_action;
  if (confidence === "high") return "Use the ranked evidence and citations to draft the answer.";
  return "Review the retrieved citations and consider a scoped follow-up retrieval if the answer needs stronger grounding.";
}

function authorityFor(node: GraphNode): number {
  if (node.id.startsWith("wiki:")) return 0.95;
  if (node.id.startsWith("symbol:") || node.id.startsWith("file:")) return 0.9;
  if (node.id.startsWith("endpoint:") || node.id.startsWith("route:") || node.id.startsWith("table:")) return 0.85;
  if (node.id.startsWith("project:")) return 0.7;
  return 0.5;
}

function round(value: number): number {
  return Math.round(value * 100) / 100;
}
