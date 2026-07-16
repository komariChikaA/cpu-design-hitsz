import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
let failed = false;

function fail(message) {
  failed = true;
  console.error(`ERROR: ${message}`);
}

for (const name of ["system", "core", "compact"]) {
  const model = JSON.parse(await fs.readFile(path.join(here, "model", `${name}.json`), "utf8"));
  const nodeIds = new Set();
  const portIds = new Set();
  const edgeIds = new Set();

  for (const node of model.nodes) {
    if (nodeIds.has(node.id)) fail(`${name}: duplicate node ${node.id}`);
    nodeIds.add(node.id);
    for (const port of node.ports) {
      const id = `${node.id}.${port.id}`;
      if (portIds.has(id)) fail(`${name}: duplicate port ${id}`);
      portIds.add(id);
      if (!["WEST", "EAST"].includes(port.side)) fail(`${name}: unsupported side on ${id}`);
    }
  }

  for (const edge of model.edges) {
    if (edgeIds.has(edge.id)) fail(`${name}: duplicate edge ${edge.id}`);
    edgeIds.add(edge.id);
    if (!portIds.has(edge.from)) fail(`${name}: missing source ${edge.from}`);
    if (!portIds.has(edge.to)) fail(`${name}: missing target ${edge.to}`);
  }

  const svg = await fs.readFile(path.join(here, `${name}.svg`), "utf8");
  if (!svg.startsWith("<?xml")) fail(`${name}: SVG is missing XML declaration`);
  if (!svg.includes("viewBox=")) fail(`${name}: SVG is missing viewBox`);
  if (svg.includes("NaN") || svg.includes("undefined")) fail(`${name}: SVG contains invalid coordinates`);
  if ((svg.match(/class="node /g) ?? []).length !== model.nodes.length) fail(`${name}: rendered node count differs from model`);
  if ((svg.match(/class="edge edge-/g) ?? []).length < model.edges.length) fail(`${name}: one or more edges were not routed`);

  const png = await fs.readFile(path.join(here, `${name}.png`));
  const pngSignature = "89504e470d0a1a0a";
  if (png.subarray(0, 8).toString("hex") !== pngSignature) fail(`${name}: PNG preview has an invalid signature`);
  if (png.length < 10000) fail(`${name}: PNG preview is unexpectedly small`);

  console.log(`OK: ${name} — ${model.nodes.length} nodes, ${model.edges.length} modeled edges, PNG ${png.length} bytes`);
}

if (failed) process.exit(1);
