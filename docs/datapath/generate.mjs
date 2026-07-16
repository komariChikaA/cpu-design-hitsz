import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import ELK from "elkjs/lib/elk.bundled.js";

const here = path.dirname(fileURLToPath(import.meta.url));
const elk = new ELK();
const requested = process.argv.slice(2);
const diagrams = requested.length ? requested : ["system", "core", "compact"];

const palette = {
  data: { stroke: "#2563eb", width: 2.8, dash: "", marker: "arrow-data" },
  control: { stroke: "#d97706", width: 1.8, dash: "", marker: "arrow-control" },
  handshake: { stroke: "#7c3aed", width: 2.0, dash: "7 5", marker: "arrow-handshake" },
  target: { stroke: "#dc2626", width: 2.1, dash: "9 6", marker: "arrow-target" },
  current: { stroke: "#475569", width: 2.0, dash: "3 4", marker: "arrow-current" }
};

function escapeXml(value = "") {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

function textWidth(text, size = 12) {
  let units = 0;
  for (const char of String(text)) units += /[\u2e80-\u9fff]/u.test(char) ? 1 : 0.58;
  return Math.ceil(units * size + 18);
}

function nodeSize(node) {
  const west = node.ports.filter((port) => port.side === "WEST").length;
  const east = node.ports.filter((port) => port.side === "EAST").length;
  const widestPort = Math.max(...node.ports.map((port) => textWidth(port.label, 11)), 0);
  const widestWest = Math.max(...node.ports.filter((port) => port.side === "WEST").map((port) => textWidth(port.label, 11)), 0);
  const widestEast = Math.max(...node.ports.filter((port) => port.side === "EAST").map((port) => textWidth(port.label, 11)), 0);
  const twoSidedWidth = widestWest && widestEast ? widestWest + widestEast + 36 : 0;
  const titleWidth = Math.max(textWidth(node.label, 16), textWidth(node.subtitle, 11));
  return {
    width: node.width ?? Math.max(190, titleWidth + 28, widestPort + 48, twoSidedWidth),
    height: node.height ?? Math.max(94, 62 + Math.max(west, east) * 22)
  };
}

function toElkGraph(model) {
  const stageIndex = new Map(model.stages.map((stage, index) => [stage.id, index]));
  const spacing = model.layout ?? {};
  return {
    id: model.id,
    layoutOptions: {
      "elk.algorithm": "layered",
      "elk.direction": model.direction ?? "RIGHT",
      "elk.edgeRouting": "ORTHOGONAL",
      "elk.spacing.nodeNode": String(spacing.nodeNode ?? 48),
      "elk.layered.spacing.nodeNodeBetweenLayers": String(spacing.nodeNodeBetweenLayers ?? 105),
      "elk.layered.spacing.edgeNodeBetweenLayers": String(spacing.edgeNodeBetweenLayers ?? 26),
      "elk.layered.spacing.edgeEdgeBetweenLayers": String(spacing.edgeEdgeBetweenLayers ?? 14),
      "elk.layered.nodePlacement.strategy": "BRANDES_KOEPF",
      "elk.layered.crossingMinimization.strategy": "LAYER_SWEEP",
      "elk.layered.considerModelOrder.strategy": "NODES_AND_EDGES",
      "elk.layered.cycleBreaking.strategy": "GREEDY_MODEL_ORDER",
      "elk.partitioning.activate": "true",
      "elk.padding": "[top=36,left=36,bottom=36,right=36]"
    },
    children: model.nodes.map((node) => {
      const size = nodeSize(node);
      const sideCounts = new Map();
      for (const port of node.ports) sideCounts.set(port.side, (sideCounts.get(port.side) ?? 0) + 1);
      const sideIndices = new Map();
      return {
        id: node.id,
        width: size.width,
        height: size.height,
        layoutOptions: {
          "elk.portConstraints": "FIXED_POS",
          "elk.partitioning.partition": String(stageIndex.get(node.stage) ?? 0)
        },
        ports: node.ports.map((port) => {
          const index = sideIndices.get(port.side) ?? 0;
          sideIndices.set(port.side, index + 1);
          const count = sideCounts.get(port.side);
          const top = 58;
          const bottom = size.height - 14;
          const centerY = count === 1 ? (top + bottom) / 2 : top + index * (bottom - top) / (count - 1);
          return {
            id: `${node.id}.${port.id}`,
            width: 8,
            height: 8,
            x: port.side === "WEST" ? -4 : size.width - 4,
            y: centerY - 4,
            layoutOptions: { "elk.port.side": port.side }
          };
        })
      };
    }),
    edges: model.edges.map((edge) => ({
      id: edge.id,
      sources: [edge.from],
      targets: [edge.to],
      labels: edge.label
        ? [{ id: `${edge.id}.label`, text: edge.label, width: textWidth(edge.label), height: 22 }]
        : []
    }))
  };
}

function edgePath(section) {
  const points = [section.startPoint, ...(section.bendPoints ?? []), section.endPoint];
  return points.map((point, index) => `${index ? "L" : "M"} ${point.x} ${point.y}`).join(" ");
}

function edgeMidpoint(section) {
  const points = [section.startPoint, ...(section.bendPoints ?? []), section.endPoint];
  const segments = [];
  let total = 0;
  for (let index = 1; index < points.length; index += 1) {
    const from = points[index - 1];
    const to = points[index];
    const length = Math.abs(to.x - from.x) + Math.abs(to.y - from.y);
    segments.push({ from, to, length });
    total += length;
  }
  let target = total / 2;
  for (const segment of segments) {
    if (target <= segment.length) {
      const ratio = segment.length ? target / segment.length : 0;
      return {
        x: segment.from.x + (segment.to.x - segment.from.x) * ratio,
        y: segment.from.y + (segment.to.y - segment.from.y) * ratio
      };
    }
    target -= segment.length;
  }
  return points.at(-1);
}

function renderEdge(edge, modelEdge) {
  const style = palette[modelEdge.type] ?? palette.data;
  const sections = edge.sections ?? [];
  const paths = sections.map((section) =>
    `<path class="edge edge-${escapeXml(modelEdge.type)}" d="${edgePath(section)}" ` +
    `stroke="${style.stroke}" stroke-width="${style.width}" stroke-dasharray="${style.dash}" ` +
    `marker-end="url(#${style.marker})"/>`
  ).join("\n");

  if (!modelEdge.label || !sections.length) return paths;
  const elkLabel = edge.labels?.[0];
  const point = elkLabel?.x != null
    ? { x: elkLabel.x + elkLabel.width / 2, y: elkLabel.y + elkLabel.height / 2 }
    : edgeMidpoint(sections[0]);
  const width = textWidth(modelEdge.label, 10);
  return `${paths}\n<g class="edge-label" transform="translate(${point.x - width / 2} ${point.y - 10})">` +
    `<rect width="${width}" height="20" rx="6" fill="#ffffff" fill-opacity="0.94" stroke="${style.stroke}" stroke-opacity="0.28"/>` +
    `<text x="${width / 2}" y="13.5" text-anchor="middle" fill="${style.stroke}">${escapeXml(modelEdge.label)}</text></g>`;
}

function renderNode(layoutNode, modelNode) {
  const kindClass = `node-${modelNode.kind ?? "logic"}`;
  const statusClass = modelNode.status ? ` status-${modelNode.status}` : "";
  const portModel = new Map(modelNode.ports.map((port) => [`${modelNode.id}.${port.id}`, port]));
  const portSvg = (layoutNode.ports ?? []).map((port) => {
    const meta = portModel.get(port.id);
    const cx = port.x + port.width / 2;
    const cy = port.y + port.height / 2;
    const east = meta.side === "EAST";
    const tx = east ? layoutNode.width - 14 : 14;
    return `<g class="port port-${meta.side.toLowerCase()}">` +
      `<circle cx="${cx}" cy="${cy}" r="4"/>` +
      `<text x="${tx}" y="${cy + 4}" text-anchor="${east ? "end" : "start"}">${escapeXml(meta.label)}</text></g>`;
  }).join("\n");

  const badge = modelNode.status === "partial"
    ? `<g transform="translate(${layoutNode.width - 76} 12)"><rect width="62" height="20" rx="10" fill="#fff7ed" stroke="#f59e0b"/><text x="31" y="14" text-anchor="middle" class="badge">TODO</text></g>`
    : "";

  return `<g id="node-${escapeXml(modelNode.id)}" class="node ${kindClass}${statusClass}" transform="translate(${layoutNode.x} ${layoutNode.y})">` +
    `<rect class="node-body" width="${layoutNode.width}" height="${layoutNode.height}" rx="14"/>` +
    `<rect class="node-header" x="1" y="1" width="${layoutNode.width - 2}" height="43" rx="13"/>` +
    `<path class="header-cut" d="M 1 43 H ${layoutNode.width - 1}"/>` +
    `<text class="node-title" x="16" y="23">${escapeXml(modelNode.label)}</text>` +
    `<text class="node-subtitle" x="16" y="38">${escapeXml(modelNode.subtitle ?? "")}</text>` +
    badge + portSvg + `</g>`;
}

function renderStageBands(layout, model) {
  const byId = new Map(model.nodes.map((node) => [node.id, node]));
  return model.stages.map((stage) => {
    const nodes = layout.children.filter((node) => byId.get(node.id)?.stage === stage.id);
    if (!nodes.length) return "";
    const minX = Math.min(...nodes.map((node) => node.x)) - 26;
    const maxX = Math.max(...nodes.map((node) => node.x + node.width)) + 26;
    return `<g class="stage-band"><rect x="${minX}" y="0" width="${maxX - minX}" height="${layout.height}" rx="18" fill="${stage.color}"/>` +
      `<text x="${minX + 16}" y="25">${escapeXml(stage.label)}</text></g>`;
  }).join("\n");
}

function markers() {
  return Object.entries(palette).map(([name, style]) =>
    `<marker id="arrow-${name}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">` +
    `<path d="M 0 0 L 10 5 L 0 10 z" fill="${style.stroke}"/></marker>`
  ).join("\n");
}

function renderLegend() {
  const items = [
    ["data", "32-bit data / 数据"],
    ["control", "control / 控制"],
    ["handshake", "handshake / 跨周期握手"],
    ["target", "target only / 目标连接"],
    ["current", "current special case / 当前特例"]
  ];
  let x = 0;
  return `<g class="legend">${items.map(([type, label]) => {
    const style = palette[type];
    const width = textWidth(label, 11) + 42;
    const item = `<g transform="translate(${x} 0)"><path d="M 0 8 H 28" stroke="${style.stroke}" stroke-width="${style.width}" stroke-dasharray="${style.dash}" marker-end="url(#${style.marker})"/>` +
      `<text x="38" y="12">${escapeXml(label)}</text></g>`;
    x += width;
    return item;
  }).join("")}</g>`;
}

function renderSvg(layout, model) {
  const offsetX = 70;
  const offsetY = 138;
  const footerHeight = 56 + model.notes.length * 21;
  const width = Math.max(1280, layout.width + offsetX * 2);
  const height = layout.height + offsetY + footerHeight;
  const nodeModel = new Map(model.nodes.map((node) => [node.id, node]));
  const edgeModel = new Map(model.edges.map((edge) => [edge.id, edge]));
  const edges = layout.edges.map((edge) => renderEdge(edge, edgeModel.get(edge.id))).join("\n");
  const nodes = layout.children.map((node) => renderNode(node, nodeModel.get(node.id))).join("\n");
  const notesY = offsetY + layout.height + 35;

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="100%" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="title desc">
  <title id="title">${escapeXml(model.title)}</title>
  <desc id="desc">${escapeXml(model.subtitle)}</desc>
  <metadata>${escapeXml(JSON.stringify({ model: model.id, nodes: model.nodes.length, edges: model.edges.length }))}</metadata>
  <defs>
    ${markers()}
    <filter id="node-shadow" x="-20%" y="-20%" width="140%" height="150%"><feDropShadow dx="0" dy="3" stdDeviation="4" flood-color="#0f172a" flood-opacity="0.12"/></filter>
    <style><![CDATA[
      text { font-family: Inter, "Noto Sans SC", "Microsoft YaHei", sans-serif; }
      .edge { fill: none; stroke-linecap: round; stroke-linejoin: round; }
      .edge-label text { font-size: 10px; font-weight: 650; letter-spacing: .2px; }
      .stage-band rect { opacity: .64; stroke: #cbd5e1; stroke-width: 1; stroke-dasharray: 5 6; }
      .stage-band text { font-size: 13px; font-weight: 750; fill: #475569; letter-spacing: .8px; }
      .node { filter: url(#node-shadow); }
      .node-body { fill: #ffffff; stroke: #334155; stroke-width: 1.5; }
      .node-header { fill: #f8fafc; stroke: none; }
      .header-cut { stroke: #e2e8f0; stroke-width: 1; }
      .node-title { font-size: 16px; font-weight: 760; fill: #0f172a; }
      .node-subtitle { font-size: 10.5px; fill: #64748b; }
      .port circle { fill: #ffffff; stroke: #475569; stroke-width: 1.5; }
      .port text { font-size: 10.5px; font-weight: 700; fill: #334155; }
      .node-core .node-body { stroke: #4f46e5; stroke-width: 2.2; }
      .node-memory .node-body { stroke: #0284c7; }
      .node-register .node-body { stroke: #7c3aed; }
      .node-mux .node-body { stroke: #d97706; }
      .node-external .node-body { stroke: #64748b; stroke-dasharray: 7 5; }
      .node-constant .node-body { stroke: #64748b; stroke-dasharray: 3 3; }
      .status-partial .node-body { stroke: #f59e0b; stroke-dasharray: 8 5; }
      .badge { font-size: 10px; font-weight: 800; fill: #b45309; }
      .legend text { font-size: 11px; fill: #475569; }
      .note { font-size: 11px; fill: #64748b; }
    ]]></style>
  </defs>
  <rect width="${width}" height="${height}" fill="#ffffff"/>
  <g transform="translate(${offsetX} 0)">
    <text x="0" y="42" font-size="26" font-weight="800" fill="#0f172a">${escapeXml(model.title)}</text>
    <text x="0" y="68" font-size="13" fill="#64748b">${escapeXml(model.subtitle)}</text>
    <g transform="translate(0 91)">${renderLegend()}</g>
  </g>
  <g transform="translate(${offsetX} ${offsetY})">
    ${renderStageBands(layout, model)}
    <g class="edges">${edges}</g>
    <g class="nodes">${nodes}</g>
  </g>
  <g transform="translate(${offsetX} ${notesY})">
    ${model.notes.map((note, index) => `<text class="note" x="0" y="${index * 21}">• ${escapeXml(note)}</text>`).join("\n")}
  </g>
</svg>`;
}

for (const name of diagrams) {
  const modelPath = path.join(here, "model", `${name}.json`);
  const model = JSON.parse(await fs.readFile(modelPath, "utf8"));
  const layout = await elk.layout(toElkGraph(model));
  const svg = renderSvg(layout, model);
  const outputPath = path.join(here, `${name}.svg`);
  await fs.writeFile(outputPath, svg, "utf8");
  console.log(`${path.relative(process.cwd(), outputPath)}: ${model.nodes.length} nodes, ${model.edges.length} edges, viewBox ${Math.ceil(layout.width)}×${Math.ceil(layout.height)}`);
}
