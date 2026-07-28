import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { Resvg } from "@resvg/resvg-js";

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "..", "..");
const outputDir = path.join(repo, "docs", "course-report", "figures");
const inputEvidenceDir = path.join(repo, "docs", "course-report", "vcd");

const palette = {
  ink: "#162033",
  muted: "#64748b",
  grid: "#dbe4f0",
  blue: "#2563eb",
  blueFill: "#eff6ff",
  orange: "#d97706",
  orangeFill: "#fff7ed",
  purple: "#7c3aed",
  purpleFill: "#f5f3ff",
  green: "#059669",
  greenFill: "#ecfdf5",
  red: "#dc2626",
  redFill: "#fef2f2",
  slateFill: "#f8fafc",
  white: "#ffffff"
};

function esc(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function svgDocument({ width, height, title, description, body }) {
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-label="${esc(title)}">
  <title>${esc(title)}</title>
  <desc>${esc(description)}</desc>
  <defs>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="150%">
      <feDropShadow dx="0" dy="5" stdDeviation="8" flood-color="#0f172a" flood-opacity="0.12"/>
    </filter>
    <marker id="arrowBlue" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="${palette.blue}"/>
    </marker>
    <marker id="arrowOrange" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="${palette.orange}"/>
    </marker>
    <marker id="arrowPurple" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="${palette.purple}"/>
    </marker>
    <marker id="arrowInk" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="#111827"/>
    </marker>
    <marker id="arrowRed" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="#b91c1c"/>
    </marker>
    <style>
      text { font-family: "Microsoft YaHei", "Noto Sans SC", Arial, sans-serif; }
      .mono { font-family: "Cascadia Mono", Consolas, monospace; }
    </style>
  </defs>
  <rect width="${width}" height="${height}" fill="#ffffff"/>
  ${body}
</svg>`;
}

async function writeAsset(name, svg, pngWidth = 3200) {
  await fs.mkdir(outputDir, { recursive: true });
  const svgPath = path.join(outputDir, `${name}.svg`);
  const pngPath = path.join(outputDir, `${name}.png`);
  await fs.writeFile(svgPath, svg, "utf8");
  const renderer = new Resvg(svg, {
    fitTo: { mode: "width", value: pngWidth },
    font: { loadSystemFonts: true },
    background: "#ffffff"
  });
  const png = renderer.render().asPng();
  await fs.writeFile(pngPath, png);
  console.log(`${path.relative(repo, svgPath)} / ${path.relative(repo, pngPath)} (${png.length} bytes)`);
}

async function parseVcd(file) {
  const text = await fs.readFile(file, "utf8");
  const lines = text.split(/\r?\n/);
  const scopes = [];
  const definitions = new Map();
  const transitions = new Map();
  let time = 0;
  let timescale = "unknown";
  let inDefinitions = true;
  let readingTimescale = false;

  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (!line) continue;

    if (inDefinitions) {
      if (readingTimescale) {
        if (line === "$end") {
          readingTimescale = false;
        } else {
          timescale = line.replace("$end", "").trim();
          if (line.endsWith("$end")) readingTimescale = false;
        }
      } else if (line === "$timescale") {
        readingTimescale = true;
      } else if (line.startsWith("$timescale")) {
        timescale = line.replace("$timescale", "").replace("$end", "").trim();
      } else if (line.startsWith("$scope")) {
        const parts = line.split(/\s+/);
        scopes.push(parts[2]);
      } else if (line.startsWith("$upscope")) {
        scopes.pop();
      } else if (line.startsWith("$var")) {
        const match = line.match(/^\$var\s+\S+\s+(\d+)\s+(\S+)\s+(\S+)/);
        if (!match) continue;
        const width = Number(match[1]);
        const code = match[2];
        const reference = match[3];
        const fullName = [...scopes, reference].join(".");
        definitions.set(fullName, { code, width, fullName, reference });
        if (!transitions.has(code)) transitions.set(code, []);
      } else if (line.startsWith("$enddefinitions")) {
        inDefinitions = false;
      }
      continue;
    }

    if (line.startsWith("#")) {
      time = Number(line.slice(1));
      continue;
    }

    const scalar = line.match(/^([01xz])(\S+)$/i);
    if (scalar) {
      if (!transitions.has(scalar[2])) transitions.set(scalar[2], []);
      transitions.get(scalar[2]).push({ time, value: scalar[1].toLowerCase() });
      continue;
    }

    const vector = line.match(/^[br]([^\s]+)\s+(\S+)$/i);
    if (vector) {
      if (!transitions.has(vector[2])) transitions.set(vector[2], []);
      transitions.get(vector[2]).push({ time, value: vector[1].toLowerCase() });
    }
  }

  return { file, definitions, transitions, lastTime: time, timescale };
}

function findSignal(vcd, suffix, preferredScope = "TOP.miniRV_SoC.U_cpu.U_core") {
  const exact = `${preferredScope}.${suffix}`;
  if (vcd.definitions.has(exact)) return vcd.definitions.get(exact);
  const matches = [...vcd.definitions.values()].filter((item) => item.fullName.endsWith(`.${suffix}`));
  if (!matches.length) throw new Error(`Signal not found in ${path.basename(vcd.file)}: ${suffix}`);
  matches.sort((a, b) => a.fullName.length - b.fullName.length);
  return matches[0];
}

function signalChanges(vcd, signal) {
  return vcd.transitions.get(signal.code) ?? [];
}

function valueAt(changes, time) {
  let low = 0;
  let high = changes.length - 1;
  let result = "x";
  while (low <= high) {
    const middle = Math.floor((low + high) / 2);
    if (changes[middle].time <= time) {
      result = changes[middle].value;
      low = middle + 1;
    } else {
      high = middle - 1;
    }
  }
  return result;
}

function normalizeBits(value, width) {
  if (/^[01]+$/.test(value)) return value.padStart(width, "0").slice(-width);
  return value;
}

function displayValue(value, width) {
  if (/^[01]+$/.test(value)) {
    const normalized = normalizeBits(value, width);
    const hex = BigInt(`0b${normalized}`).toString(16).padStart(Math.ceil(width / 4), "0");
    return `0x${hex}`;
  }
  return value.toUpperCase();
}

function firstNonZero(changes) {
  return changes.find((change) => /^[01]+$/.test(change.value) && /1/.test(change.value))?.time;
}

function firstFallingAfter(changes, time) {
  return changes.find((change) => change.time > time && change.value === "0")?.time;
}

function renderWaveform({
  vcd,
  title,
  subtitle,
  signalSpecs,
  startTime,
  endTime,
  markers
}) {
  if (!Number.isFinite(startTime) || !Number.isFinite(endTime) || endTime <= startTime) {
    throw new Error(`Invalid waveform window for ${path.basename(vcd.file)}: ${startTime}..${endTime}`);
  }
  const width = 2400;
  const labelWidth = 500;
  const plotLeft = labelWidth + 32;
  const plotRight = width - 48;
  const plotWidth = plotRight - plotLeft;
  const headerHeight = 205;
  const rowHeight = 86;
  const footerHeight = 104;
  const height = headerHeight + signalSpecs.length * rowHeight + footerHeight;
  const xForTime = (time) => plotLeft + ((time - startTime) / (endTime - startTime)) * plotWidth;
  const body = [];

  body.push(`<text x="54" y="62" font-size="42" font-weight="800" fill="${palette.ink}">${esc(title)}</text>`);
  body.push(`<text x="54" y="104" font-size="24" fill="${palette.muted}">${esc(subtitle)}</text>`);
  body.push(`<rect x="48" y="132" width="${width - 96}" height="54" rx="12" fill="${palette.slateFill}" stroke="${palette.grid}"/>`);
  body.push(`<text x="70" y="167" font-size="21" fill="${palette.ink}">VCD: ${esc(path.basename(vcd.file))} · timescale ${esc(vcd.timescale)} · window ${startTime}–${endTime} ticks</text>`);

  const tickCount = 10;
  for (let index = 0; index <= tickCount; index += 1) {
    const time = startTime + ((endTime - startTime) * index) / tickCount;
    const x = plotLeft + (plotWidth * index) / tickCount;
    body.push(`<line x1="${x}" y1="${headerHeight - 12}" x2="${x}" y2="${height - footerHeight + 4}" stroke="${palette.grid}" stroke-width="1.4"/>`);
    body.push(`<text x="${x}" y="${headerHeight - 20}" text-anchor="middle" font-size="17" fill="${palette.muted}">${Math.round(time)}</text>`);
  }

  signalSpecs.forEach((spec, rowIndex) => {
    const signal = findSignal(vcd, spec.signal, spec.scope);
    const changes = signalChanges(vcd, signal);
    const yTop = headerHeight + rowIndex * rowHeight;
    const yCenter = yTop + rowHeight / 2;
    const fill = rowIndex % 2 === 0 ? "#ffffff" : "#f8fafc";
    body.push(`<rect x="48" y="${yTop}" width="${width - 96}" height="${rowHeight}" fill="${fill}"/>`);
    body.push(`<line x1="48" y1="${yTop + rowHeight}" x2="${width - 48}" y2="${yTop + rowHeight}" stroke="${palette.grid}"/>`);
    body.push(`<text x="68" y="${yTop + 34}" font-size="23" font-weight="750" fill="${palette.ink}" class="mono">${esc(spec.label)}</text>`);
    body.push(`<text x="68" y="${yTop + 62}" font-size="16" fill="${palette.muted}" class="mono">${esc(signal.reference)} [${signal.width} bit]</text>`);

    const windowChanges = [
      { time: startTime, value: valueAt(changes, startTime) },
      ...changes.filter((change) => change.time > startTime && change.time < endTime),
      { time: endTime, value: valueAt(changes, endTime) }
    ];

    if (signal.width === 1) {
      const yHigh = yCenter - 22;
      const yLow = yCenter + 22;
      let pathData = "";
      for (let index = 0; index < windowChanges.length - 1; index += 1) {
        const current = windowChanges[index];
        const next = windowChanges[index + 1];
        const x1 = xForTime(current.time);
        const x2 = xForTime(next.time);
        const y = current.value === "1" ? yHigh : current.value === "0" ? yLow : yCenter;
        if (!pathData) pathData = `M ${x1} ${y}`;
        pathData += ` L ${x2} ${y}`;
        if (index < windowChanges.length - 2) {
          const nextY = next.value === "1" ? yHigh : next.value === "0" ? yLow : yCenter;
          pathData += ` L ${x2} ${nextY}`;
        }
      }
      body.push(`<path d="${pathData}" fill="none" stroke="${spec.color ?? palette.blue}" stroke-width="4" stroke-linejoin="round"/>`);
    } else {
      for (let index = 0; index < windowChanges.length - 1; index += 1) {
        const current = windowChanges[index];
        const next = windowChanges[index + 1];
        const x1 = xForTime(current.time);
        const x2 = xForTime(next.time);
        const segmentWidth = Math.max(1, x2 - x1);
        const value = displayValue(current.value, signal.width);
        body.push(`<rect x="${x1}" y="${yCenter - 25}" width="${segmentWidth}" height="50" fill="${spec.fill ?? palette.blueFill}" stroke="${spec.color ?? palette.blue}" stroke-width="2"/>`);
        if (segmentWidth > 86) {
          const shown = value.length > 14 && segmentWidth < 220 ? `${value.slice(0, 11)}…` : value;
          body.push(`<text x="${x1 + segmentWidth / 2}" y="${yCenter + 7}" text-anchor="middle" font-size="18" font-weight="650" fill="${palette.ink}" class="mono">${esc(shown)}</text>`);
        }
      }
    }
  });

  for (const marker of markers) {
    const x = xForTime(marker.time);
    body.push(`<line x1="${x}" y1="132" x2="${x}" y2="${height - footerHeight + 4}" stroke="${marker.color ?? palette.red}" stroke-width="3" stroke-dasharray="10 8"/>`);
    body.push(`<rect x="${Math.min(x + 8, width - 300)}" y="139" width="278" height="38" rx="9" fill="${marker.fill ?? palette.redFill}" stroke="${marker.color ?? palette.red}"/>`);
    body.push(`<text x="${Math.min(x + 20, width - 288)}" y="165" font-size="18" font-weight="750" fill="${marker.color ?? palette.red}">${esc(marker.label)}</text>`);
  }

  body.push(`<text x="54" y="${height - 52}" font-size="19" fill="${palette.muted}">蓝色：数据/普通控制　橙色：访存或多周期控制　红色虚线：关键事件。数值按十六进制显示。</text>`);

  return svgDocument({
    width,
    height,
    title,
    description: `${title}; generated directly from ${path.basename(vcd.file)}`,
    body: body.join("\n")
  });
}

function box({ x, y, width, height, title, subtitle, lines = [], stroke = palette.blue, fill = palette.white, titleSize = 28, lineSize = 20 }) {
  const body = [];
  body.push(`<g filter="url(#shadow)">`);
  body.push(`<rect x="${x}" y="${y}" width="${width}" height="${height}" rx="18" fill="${fill}" stroke="${stroke}" stroke-width="3"/>`);
  body.push(`<rect x="${x + 1.5}" y="${y + 1.5}" width="${width - 3}" height="74" rx="16" fill="${palette.slateFill}"/>`);
  body.push(`<line x1="${x}" y1="${y + 74}" x2="${x + width}" y2="${y + 74}" stroke="${palette.grid}" stroke-width="2"/>`);
  body.push(`<text x="${x + 22}" y="${y + 36}" font-size="${titleSize}" font-weight="800" fill="${palette.ink}">${esc(title)}</text>`);
  if (subtitle) body.push(`<text x="${x + 22}" y="${y + 62}" font-size="17" fill="${palette.muted}">${esc(subtitle)}</text>`);
  lines.forEach((line, index) => {
    body.push(`<text x="${x + 22}" y="${y + 112 + index * 34}" font-size="${lineSize}" font-weight="650" fill="${palette.ink}" class="mono">${esc(line)}</text>`);
  });
  body.push(`</g>`);
  return body.join("\n");
}

function arrow({ x1, y1, x2, y2, color = palette.blue, label = "", dashed = false, bend = null }) {
  let data;
  if (bend) {
    data = `M ${x1} ${y1} L ${bend.x} ${y1} L ${bend.x} ${y2} L ${x2} ${y2}`;
  } else {
    data = `M ${x1} ${y1} L ${x2} ${y2}`;
  }
  const marker = color === palette.orange ? "arrowOrange" : color === palette.purple ? "arrowPurple" : "arrowBlue";
  const body = [`<path d="${data}" fill="none" stroke="${color}" stroke-width="4" ${dashed ? 'stroke-dasharray="12 9"' : ""} marker-end="url(#${marker})"/>`];
  if (label) {
    const tx = bend ? bend.x + 10 : (x1 + x2) / 2;
    const ty = bend ? Math.min(y1, y2) - 10 : (y1 + y2) / 2 - 12;
    body.push(`<text x="${tx}" y="${ty}" font-size="18" font-weight="700" fill="${color}" class="mono">${esc(label)}</text>`);
  }
  return body.join("\n");
}

function engineeringModule({ x, y, width, height, title, subtitle = "", lines = [], accent = "#111827" }) {
  const parts = [
    `<g>`,
    `<rect x="${x}" y="${y}" width="${width}" height="${height}" fill="#ffffff" stroke="#111827" stroke-width="3"/>`,
    `<rect x="${x}" y="${y}" width="${width}" height="58" fill="#e5e7eb" stroke="#111827" stroke-width="3"/>`,
    `<rect x="${x}" y="${y}" width="8" height="${height}" fill="${accent}"/>`,
    `<text x="${x + 22}" y="${y + 38}" font-size="30" font-weight="800" fill="#111827">${esc(title)}</text>`
  ];
  if (subtitle) {
    parts.push(`<text x="${x + 20}" y="${y + 86}" font-size="24" fill="#475569">${esc(subtitle)}</text>`);
  }
  lines.forEach((line, index) => {
    parts.push(`<text x="${x + 20}" y="${y + 124 + index * 38}" font-size="25" fill="#111827" class="mono">${esc(line)}</text>`);
  });
  parts.push(`</g>`);
  return parts.join("\n");
}

function engineeringRegister({ x, y, height, name }) {
  return [
    `<rect x="${x}" y="${y}" width="86" height="${height}" fill="#374151" stroke="#111827" stroke-width="3"/>`,
    `<text transform="translate(${x + 55} ${y + height - 30}) rotate(-90)" font-size="29" font-weight="800" fill="#ffffff">${esc(name)}</text>`
  ].join("\n");
}

function engineeringPath({ points, color = "#1d4ed8", width = 5, marker = "arrowBlue", dashed = false, label = "", labelX = 0, labelY = 0, fontSize = 25 }) {
  const pathData = points.map((point, index) => `${index === 0 ? "M" : "L"} ${point[0]} ${point[1]}`).join(" ");
  const parts = [
    `<path d="${pathData}" fill="none" stroke="${color}" stroke-width="${width}" ${dashed ? 'stroke-dasharray="13 10"' : ""} marker-end="url(#${marker})"/>`
  ];
  if (label) {
    parts.push(`<text x="${labelX}" y="${labelY}" font-size="${fontSize}" font-weight="700" fill="${color}" class="mono" style="paint-order:stroke;stroke:#fff;stroke-width:8;stroke-linejoin:round">${esc(label)}</text>`);
  }
  return parts.join("\n");
}

function renderSingleCycleDatapath() {
  const width = 2400;
  const height = 1460;
  const body = [];
  const data = "#1d4ed8";
  const control = "#b45309";
  const writeback = "#6d28d9";

  body.push(`<text x="48" y="58" font-size="44" font-weight="800" fill="#111827">miniRV single-cycle CPU datapath</text>`);
  body.push(`<text x="48" y="96" font-size="26" fill="#475569">Report overview; IF / ID / EX / MEM / WB are logical regions, not pipeline registers.</text>`);
  body.push(`<line x1="48" y1="120" x2="2352" y2="120" stroke="#111827" stroke-width="3"/>`);

  const mainY = 285;
  const mainH = 300;
  const nodes = [
    { x: 48, width: 250, title: "NPC", subtitle: "next PC", lines: ["pc, pc4", "jalr_addr, br"] },
    { x: 346, width: 230, title: "PC", subtitle: "program counter", lines: ["npc [31:0]", "pc [31:0]"] },
    { x: 624, width: 280, title: "Inst ROM", subtitle: "instruction memory", lines: ["inst_addr", "inst_out"] },
    { x: 952, width: 300, title: "Fields", subtitle: "instruction decode", lines: ["opcode / funct", "rs1 / rs2 / rd"] },
    { x: 1300, width: 300, title: "RF", subtitle: "register file", lines: ["rD1 / rD2", "wR / wD / we"] },
    { x: 1648, width: 300, title: "MUX A/B", subtitle: "ALU operands", lines: ["rf_rd1 / pc", "rf_rd2 / ext"] },
    { x: 1996, width: 356, title: "ALU", subtitle: "execute / branch", lines: ["a, b, op", "c, br"] }
  ];
  nodes.forEach((node, index) => {
    body.push(engineeringModule({
      x: node.x,
      y: mainY,
      width: node.width,
      height: mainH,
      title: node.title,
      subtitle: node.subtitle,
      lines: node.lines,
      accent: index === 0 ? control : index === 4 ? writeback : data,
      titleSize: 32,
      lineSize: 27
    }));
  });
  for (let index = 0; index < nodes.length - 1; index += 1) {
    body.push(engineeringPath({
      points: [[nodes[index].x + nodes[index].width, 435], [nodes[index + 1].x, 435]],
      width: 5
    }));
  }

  // The two top routing lanes keep PC feedback away from module labels.
  body.push(engineeringPath({
    points: [[2174, mainY], [2174, 185], [173, 185], [173, mainY]],
    color: control,
    marker: "arrowOrange",
    dashed: true,
    label: "branch result -> NPC",
    labelX: 900,
    labelY: 174,
    fontSize: 28
  }));
  body.push(engineeringPath({
    points: [[461, mainY], [461, 225], [225, 225], [225, mainY]],
    color: data,
    marker: "arrowBlue",
    label: "pc / pc + 4",
    labelX: 285,
    labelY: 216,
    fontSize: 26
  }));

  body.push(engineeringModule({
    x: 80, y: 720, width: 420, height: 250,
    title: "Controller", subtitle: "decode -> control",
    lines: ["npc_op / alu_op", "ram_rop / ram_wop", "rf_we / rf_wsel"],
    accent: control, lineSize: 27
  }));
  body.push(engineeringModule({
    x: 560, y: 720, width: 340, height: 250,
    title: "SEXT", subtitle: "immediate extension",
    lines: ["imm [31:7]", "ext [31:0]"],
    accent: data, lineSize: 27
  }));

  const lowerY = 1080;
  const lowerH = 245;
  const lowerNodes = [
    { x: 1980, width: 372, title: "MREQ", subtitle: "memory request", lines: ["ram_addr / ram_wdata", "ram_ren / ram_wen"] },
    { x: 1530, width: 400, title: "Data RAM", subtitle: "data memory", lines: ["data_addr / data_wdata", "data_rdata"] },
    { x: 1110, width: 370, title: "MEXT", subtitle: "load extension", lines: ["din / op / byte_offs", "ext [31:0]"] },
    { x: 660, width: 400, title: "WB MUX", subtitle: "write-back select", lines: ["ALU / PC+4 / EXT / RAM", "rf_wD [31:0]"] }
  ];
  lowerNodes.forEach((node, index) => {
    body.push(engineeringModule({
      x: node.x,
      y: lowerY,
      width: node.width,
      height: lowerH,
      title: node.title,
      subtitle: node.subtitle,
      lines: node.lines,
      accent: index === 3 ? writeback : data,
      titleSize: 31,
      lineSize: 26
    }));
  });

  body.push(engineeringPath({ points: [[2174, 585], [2174, 1080]], width: 5 }));
  body.push(engineeringPath({ points: [[1980, 1202], [1930, 1202]], width: 5 }));
  body.push(engineeringPath({ points: [[1530, 1202], [1480, 1202]], width: 5 }));
  body.push(engineeringPath({ points: [[1110, 1202], [1060, 1202]], width: 5 }));
  body.push(engineeringPath({
    points: [[660, 1202], [530, 1202], [530, 620], [1450, 620], [1450, 585]],
    color: writeback,
    marker: "arrowPurple",
    width: 5,
    label: "rf_wD",
    labelX: 1080,
    labelY: 608,
    fontSize: 27
  }));
  body.push(engineeringPath({
    points: [[730, 720], [730, 650], [1798, 650], [1798, 585]],
    width: 5,
    label: "ext",
    labelX: 1220,
    labelY: 638,
    fontSize: 27
  }));
  body.push(engineeringPath({
    points: [[1102, 585], [1102, 680], [290, 680], [290, 720]],
    color: control,
    marker: "arrowOrange",
    width: 4,
    label: "opcode / funct",
    labelX: 610,
    labelY: 668,
    fontSize: 27
  }));

  // One control bus below the logic blocks; short vertical taps avoid text crossings.
  body.push(engineeringPath({
    points: [[80, 845], [28, 845], [28, 435], [48, 435]],
    color: control,
    marker: "arrowOrange",
    width: 4
  }));
  body.push(`<path d="M 290 970 L 290 1040 L 2190 1040" fill="none" stroke="${control}" stroke-width="4"/>`);
  [
    [1798, 1040, 585],
    [2060, 1040, 1080],
    [860, 1040, 1080]
  ].forEach(([x, y1, y2]) => {
    body.push(`<path d="M ${x} ${y1} L ${x} ${y2}" fill="none" stroke="${control}" stroke-width="4" marker-end="url(#arrowOrange)"/>`);
  });
  body.push(`<text x="1330" y="1026" text-anchor="middle" font-size="27" font-weight="700" fill="${control}" style="paint-order:stroke;stroke:#fff;stroke-width:8">control bus: alu_op / ram_op / rf control</text>`);

  body.push(`<rect x="80" y="1055" width="510" height="285" fill="#f8fafc" stroke="#64748b" stroke-width="2"/>`);
  body.push(`<text x="108" y="1102" font-size="30" font-weight="800" fill="#111827">Reading guide</text>`);
  body.push(`<text x="108" y="1150" font-size="26" fill="#111827">1. Main row: fetch, decode, execute</text>`);
  body.push(`<text x="108" y="1194" font-size="26" fill="#111827">2. Lower row: memory and write-back</text>`);
  body.push(`<text x="108" y="1238" font-size="26" fill="#111827">3. No stage registers are present</text>`);
  body.push(`<text x="108" y="1282" font-size="26" fill="#111827">4. Detail figures list every RTL port</text>`);

  body.push(`<line x1="48" y1="1390" x2="2352" y2="1390" stroke="#111827" stroke-width="2"/>`);
  body.push(`<text x="48" y="1432" font-size="27" fill="#111827">Blue: 32-bit data  |  Brown: control / branch  |  Purple: register-file write-back</text>`);

  return svgDocument({
    width,
    height,
    title: "miniRV single-cycle CPU datapath",
    description: "Readable A4 landscape overview of the non-pipelined RTL datapath",
    body: body.join("\n")
  });
}

function renderPipelineDatapath() {
  const width = 2400;
  const height = 1460;
  const body = [];
  const data = "#1d4ed8";
  const control = "#b45309";
  const forward = "#6d28d9";
  const hazard = "#b91c1c";

  body.push(`<text x="48" y="58" font-size="44" font-weight="800" fill="#111827">miniRV five-stage pipelined CPU datapath</text>`);
  body.push(`<text x="48" y="96" font-size="26" fill="#475569">Block-level report view; exact register payloads and control conditions are listed below the drawing.</text>`);
  body.push(`<line x1="48" y1="120" x2="2352" y2="120" stroke="#111827" stroke-width="3"/>`);

  const stageY = 285;
  const stageH = 330;
  const stageW = 360;
  const regW = 72;
  const stageXs = [48, 516, 984, 1452, 1920];
  const regXs = [420, 888, 1356, 1824];
  const moduleLines = [
    ["PC / next-PC", "ifetch_req, ifetch_addr", "ifetch_inst, ifetch_valid"],
    ["Controller / SEXT / RF", "id_inst, id_pc", "rf_rd1, rf_rd2, ext"],
    ["Forward MUX / ALU", "alu_a, alu_b, alu_c", "br, ex_bj_target"],
    ["MREQ / AXI DATA / MEXT", "daccess_ren, daccess_wen", "ram_ext, memory_freeze"],
    ["WB MUX / RF write", "wb_rd, wb_rf_we", "rf_wD, wb_valid"]
  ];
  ["IF", "ID", "EX", "MEM", "WB"].forEach((name, index) => {
    body.push(engineeringModule({
      x: stageXs[index],
      y: stageY,
      width: stageW,
      height: stageH,
      title: name,
      subtitle: moduleLines[index][0],
      lines: moduleLines[index].slice(1),
      accent: index === 1 ? control : index === 4 ? forward : data,
      titleSize: 34,
      lineSize: 28
    }));
  });
  ["IF / ID", "ID / EX", "EX / MEM", "MEM / WB"].forEach((name, index) => {
    body.push(engineeringRegister({ x: regXs[index], y: stageY, height: stageH, name }));
  });

  [[408, 420], [492, 516], [876, 888], [960, 984], [1344, 1356], [1428, 1452], [1812, 1824], [1896, 1920]].forEach(([x1, x2]) => {
    body.push(engineeringPath({ points: [[x1, 450], [x2, 450]], width: 5 }));
  });

  // Two reserved routing lanes above the stage blocks keep feedback labels clear.
  body.push(engineeringPath({
    points: [[1164, stageY], [1164, 205], [228, 205], [228, stageY]],
    color: control,
    marker: "arrowOrange",
    dashed: true,
    label: "branch redirect: ex_bj_target -> PC",
    labelX: 540,
    labelY: 192,
    fontSize: 28
  }));
  body.push(engineeringPath({
    points: [[2100, stageY], [2100, 155], [696, 155], [696, stageY]],
    color: forward,
    marker: "arrowPurple",
    label: "write-back: rf_wD -> register file",
    labelX: 1260,
    labelY: 143,
    fontSize: 28
  }));

  // Supporting units are separated from the stage row. Paths enter from box edges only.
  body.push(engineeringModule({
    x: 90, y: 790, width: 560, height: 235,
    title: "AXI Master", subtitle: "direct AXI access (no cache)",
    lines: ["AR/R: instruction + data read", "AW/W/B: data write"],
    accent: data, lineSize: 27
  }));
  body.push(engineeringModule({
    x: 825, y: 790, width: 600, height: 235,
    title: "Forward Unit", subtitle: "EX/MEM and MEM/WB bypass",
    lines: ["MEM hit -> select 01", "WB hit -> select 10"],
    accent: forward, lineSize: 27
  }));
  body.push(engineeringModule({
    x: 1600, y: 790, width: 710, height: 235,
    title: "Hazard Control", subtitle: "stall / bubble / flush / resume",
    lines: ["load_use_hazard, duplicate", "memory_freeze, ex_bj_f"],
    accent: hazard, lineSize: 27
  }));

  body.push(engineeringPath({ points: [[260, 790], [260, 705], [170, 705], [170, 615]], width: 5 }));
  body.push(engineeringPath({ points: [[480, 790], [480, 720], [1632, 720], [1632, 615]], width: 5 }));
  body.push(engineeringPath({ points: [[1125, 790], [1125, 700], [1164, 700], [1164, 615]], color: forward, marker: "arrowPurple", width: 5 }));
  body.push(engineeringPath({ points: [[1632, 615], [1632, 742], [1290, 742], [1290, 790]], color: forward, marker: "arrowPurple", width: 5 }));
  body.push(engineeringPath({ points: [[2100, 615], [2100, 755], [1370, 755], [1370, 790]], color: forward, marker: "arrowPurple", width: 5 }));
  body.push(engineeringPath({
    points: [[1955, 790], [1955, 675], [456, 675]],
    color: hazard,
    marker: "arrowRed",
    dashed: true,
    width: 4
  }));
  regXs.forEach((x) => {
    body.push(`<path d="M ${x + 36} 675 L ${x + 36} 615" fill="none" stroke="${hazard}" stroke-width="4" stroke-dasharray="12 9" marker-end="url(#arrowRed)"/>`);
  });

  body.push(`<rect x="90" y="1100" width="2220" height="245" fill="#f8fafc" stroke="#64748b" stroke-width="2"/>`);
  body.push(`<text x="120" y="1145" font-size="31" font-weight="800" fill="#111827">Pipeline-register payloads</text>`);
  const payloadColumns = [
    ["IF/ID", "id_pc, id_inst", "id_valid"],
    ["ID/EX", "ex_pc, ext, rs1/rs2/rd", "control, ex_valid"],
    ["EX/MEM", "mem_alu_c, store data, rd", "control, mem_valid"],
    ["MEM/WB", "wb_alu_c, ram_ext, rd", "control, wb_valid"]
  ];
  payloadColumns.forEach((column, index) => {
    const x = 120 + index * 545;
    body.push(`<text x="${x}" y="1200" font-size="29" font-weight="800" fill="#111827">${column[0]}</text>`);
    body.push(`<text x="${x}" y="1242" font-size="25" fill="#334155" class="mono">${esc(column[1])}</text>`);
    body.push(`<text x="${x}" y="1282" font-size="25" fill="#334155" class="mono">${esc(column[2])}</text>`);
  });

  body.push(`<line x1="48" y1="1390" x2="2352" y2="1390" stroke="#111827" stroke-width="2"/>`);
  body.push(`<text x="48" y="1432" font-size="27" fill="#111827">Blue: data/AXI  |  Brown: redirect/control  |  Purple: forwarding/write-back  |  Red dashed: hazard control</text>`);

  return svgDocument({
    width,
    height,
    title: "miniRV five-stage pipelined CPU datapath",
    description: "Engineering block diagram aligned to the pipelined AXI RTL",
    body: body.join("\n")
  });
}

function engineeringState({ x, y, width, height, name, code, outputs, accent = "#111827" }) {
  const parts = [
    `<rect x="${x}" y="${y}" width="${width}" height="${height}" fill="#ffffff" stroke="#111827" stroke-width="3"/>`,
    `<rect x="${x}" y="${y}" width="${width}" height="60" fill="#e5e7eb" stroke="#111827" stroke-width="3"/>`,
    `<rect x="${x}" y="${y}" width="8" height="${height}" fill="${accent}"/>`,
    `<text x="${x + 20}" y="${y + 40}" font-size="31" font-weight="800" fill="#111827">${esc(name)}</text>`,
    `<text x="${x + width - 20}" y="${y + 40}" text-anchor="end" font-size="25" fill="#334155" class="mono">${esc(code)}</text>`
  ];
  outputs.forEach((output, index) => {
    parts.push(`<text x="${x + 22}" y="${y + 100 + index * 38}" font-size="25" fill="#111827" class="mono">${esc(output)}</text>`);
  });
  return parts.join("\n");
}

function renderAxiStateMachine() {
  const width = 2200;
  const height = 1460;
  const body = [];
  const read = "#1d4ed8";
  const write = "#b45309";

  body.push(`<text x="48" y="58" font-size="44" font-weight="800" fill="#111827">AXI4 single-transaction master state machine (no cache)</text>`);
  body.push(`<text x="48" y="96" font-size="26" fill="#475569">RTL: axi_master.v  |  request priority: data write &gt; data read &gt; instruction read</text>`);
  body.push(`<line x1="48" y1="120" x2="2152" y2="120" stroke="#111827" stroke-width="3"/>`);

  body.push(engineeringState({
    x: 740, y: 190, width: 720, height: 235,
    name: "IDLE", code: "ST_IDLE = 3'd0",
    outputs: ["dc_dev_wrdy = 1", "dc_dev_rrdy = !|dc_cpu_wen", "ic_dev_rrdy = !|dc_cpu_wen && !dc_cpu_ren"],
    accent: "#374151"
  }));
  body.push(engineeringState({
    x: 110, y: 570, width: 500, height: 205,
    name: "RADDR", code: "3'd1",
    outputs: ["ARVALID = 1", "ARADDR = aligned address"],
    accent: read
  }));
  body.push(engineeringState({
    x: 110, y: 980, width: 500, height: 205,
    name: "RDATA", code: "3'd2",
    outputs: ["RREADY = 1", "capture RDATA"],
    accent: read
  }));
  body.push(engineeringState({
    x: 1590, y: 570, width: 500, height: 245,
    name: "WSEND", code: "3'd3",
    outputs: ["AWVALID until AWREADY", "WVALID until WREADY", "WSTRB = dc_cpu_wen"],
    accent: write
  }));
  body.push(engineeringState({
    x: 1590, y: 980, width: 500, height: 205,
    name: "WRESP", code: "3'd4",
    outputs: ["BREADY = 1", "wait for BVALID"],
    accent: write
  }));

  body.push(`<circle cx="1100" cy="150" r="14" fill="#111827"/>`);
  body.push(engineeringPath({ points: [[1100, 164], [1100, 190]], color: "#111827", marker: "arrowInk", width: 4 }));
  body.push(`<text x="1130" y="176" font-size="27" font-weight="700" fill="#111827">reset</text>`);

  // Transition lines contain only short IDs. Exact Boolean expressions live in the table.
  body.push(engineeringPath({ points: [[740, 310], [630, 310], [630, 672], [610, 672]], color: read, marker: "arrowBlue", width: 5 }));
  body.push(`<text x="646" y="520" font-size="29" font-weight="800" fill="${read}">R1</text>`);
  body.push(engineeringPath({ points: [[360, 775], [360, 980]], color: read, marker: "arrowBlue", width: 5 }));
  body.push(`<text x="382" y="895" font-size="29" font-weight="800" fill="${read}">R2</text>`);
  body.push(engineeringPath({ points: [[110, 1082], [55, 1082], [55, 310], [740, 310]], color: read, marker: "arrowBlue", width: 5 }));
  body.push(`<text x="76" y="930" font-size="29" font-weight="800" fill="${read}">R3</text>`);

  body.push(engineeringPath({ points: [[1460, 310], [1570, 310], [1570, 692], [1590, 692]], color: write, marker: "arrowOrange", width: 5 }));
  body.push(`<text x="1528" y="520" font-size="29" font-weight="800" fill="${write}">W1</text>`);
  body.push(engineeringPath({ points: [[1840, 815], [1840, 980]], color: write, marker: "arrowOrange", width: 5 }));
  body.push(`<text x="1862" y="910" font-size="29" font-weight="800" fill="${write}">W2</text>`);
  body.push(engineeringPath({ points: [[2090, 1082], [2145, 1082], [2145, 310], [1460, 310]], color: write, marker: "arrowOrange", width: 5 }));
  body.push(`<text x="2088" y="930" font-size="29" font-weight="800" fill="${write}">W3</text>`);
  body.push(`<path d="M 2090 660 C 2165 660 2165 760 2030 790" fill="none" stroke="${write}" stroke-width="5" marker-end="url(#arrowOrange)"/>`);
  body.push(`<text x="1745" y="545" font-size="27" font-weight="800" fill="${write}">W0: wait / backpressure</text>`);

  body.push(`<rect x="700" y="545" width="800" height="690" fill="#f8fafc" stroke="#64748b" stroke-width="2"/>`);
  body.push(`<rect x="700" y="545" width="800" height="62" fill="#e5e7eb" stroke="#64748b" stroke-width="2"/>`);
  body.push(`<text x="728" y="587" font-size="32" font-weight="800" fill="#111827">Transition conditions</text>`);
  const transitions = [
    ["R1", "dc_cpu_ren && dc_dev_rrdy", read],
    ["", "or ic_cpu_ren && ic_dev_rrdy", read],
    ["R2", "ARVALID && ARREADY", read],
    ["R3", "RVALID && RREADY", read],
    ["W1", "|dc_cpu_wen| && dc_dev_wrdy", write],
    ["W2", "AW done && W done", write],
    ["W3", "BVALID && BREADY", write],
    ["W0", "otherwise remain in WSEND", write]
  ];
  transitions.forEach((entry, index) => {
    const y = 660 + index * 64;
    body.push(`<text x="735" y="${y}" font-size="28" font-weight="800" fill="${entry[2]}" class="mono">${entry[0]}</text>`);
    body.push(`<text x="825" y="${y}" font-size="27" fill="#111827" class="mono">${esc(entry[1])}</text>`);
  });
  body.push(`<line x1="735" y1="1180" x2="1465" y2="1180" stroke="#cbd5e1" stroke-width="2"/>`);
  body.push(`<text x="735" y="1215" font-size="24" fill="#475569">AW and W may handshake independently; both must complete before WRESP.</text>`);

  body.push(`<rect x="110" y="1270" width="1980" height="105" fill="#ffffff" stroke="#64748b" stroke-width="2"/>`);
  body.push(`<text x="142" y="1312" font-size="27" fill="#111827">32-bit, single beat, INCR, 4-byte aligned. CPU response signals are one-cycle pulses.</text>`);
  body.push(`<text x="142" y="1352" font-size="27" fill="#b91c1c">No cache is implemented: describe this path as direct AXI access, not a cache miss.</text>`);
  body.push(`<line x1="48" y1="1410" x2="2152" y2="1410" stroke="#111827" stroke-width="2"/>`);
  body.push(`<text x="48" y="1446" font-size="27" fill="#111827">Blue: read states  |  Brown: write states  |  R1-R3/W0-W3 map arrows to the condition table.</text>`);

  return svgDocument({
    width,
    height,
    title: "AXI4 single-transaction master state machine",
    description: "Engineering state diagram aligned to axi_master.v",
    body: body.join("\n")
  });
}

const lhVcd = await parseVcd(path.join(repo, "waveform", "single", "lh.vcd"));
const lhRen = findSignal(lhVcd, "daccess_ren");
const lhRvalid = findSignal(lhVcd, "daccess_rvalid");
const lhRequestTime = firstNonZero(signalChanges(lhVcd, lhRen));
const lhValidTime = firstNonZero(signalChanges(lhVcd, lhRvalid));
const lhSvg = renderWaveform({
  vcd: lhVcd,
  title: "LH 半字加载：请求、返回与符号扩展波形",
  subtitle: "展示指令、访存读使能、地址、返回数据、MEXT 扩展结果与寄存器写回",
  startTime: Math.max(0, lhRequestTime - 40),
  endTime: lhValidTime + 50,
  markers: [
    { time: lhRequestTime, label: "LH read request", color: palette.orange, fill: palette.orangeFill },
    { time: lhValidTime, label: "read valid / write-back", color: palette.red, fill: palette.redFill }
  ],
  signalSpecs: [
    { signal: "cpu_clk", label: "cpu_clk" },
    { signal: "pc", label: "pc", fill: palette.purpleFill, color: palette.purple },
    { signal: "inst", label: "inst", fill: palette.purpleFill, color: palette.purple },
    { signal: "ram_rop", label: "ram_rop", fill: palette.orangeFill, color: palette.orange },
    { signal: "daccess_ren", label: "daccess_ren", fill: palette.orangeFill, color: palette.orange },
    { signal: "daccess_addr", label: "daccess_addr" },
    { signal: "daccess_rvalid", label: "daccess_rvalid", color: palette.orange },
    { signal: "daccess_rdata", label: "daccess_rdata" },
    { signal: "ram_ext", label: "ram_ext" },
    { signal: "rf_we", label: "rf_we", color: palette.purple },
    { signal: "rf_wD", label: "rf_wD", fill: palette.purpleFill, color: palette.purple }
  ]
});

const mulVcd = await parseVcd(path.join(repo, "waveform", "single", "mul.vcd"));
const mulFlag = findSignal(mulVcd, "mul_flag");
const mulBusy = findSignal(mulVcd, "mul_div_busy");
const mulStartTime = firstNonZero(signalChanges(mulVcd, mulFlag));
const mulBusyStart = firstNonZero(signalChanges(mulVcd, mulBusy));
const mulDoneTime = firstFallingAfter(signalChanges(mulVcd, mulBusy), mulBusyStart);
const mulSvg = renderWaveform({
  vcd: mulVcd,
  title: "MUL 乘法：启动、忙等待、结果与写回波形",
  subtitle: "展示多周期乘法在 ALU 中的启动脉冲、busy 区间、结果产生和指令完成",
  startTime: Math.max(0, mulStartTime - 40),
  endTime: mulDoneTime + 60,
  markers: [
    { time: mulStartTime, label: "MUL launch", color: palette.orange, fill: palette.orangeFill },
    { time: mulDoneTime, label: "busy falls / result ready", color: palette.red, fill: palette.redFill }
  ],
  signalSpecs: [
    { signal: "cpu_clk", label: "cpu_clk" },
    { signal: "pc", label: "pc", fill: palette.purpleFill, color: palette.purple },
    { signal: "inst", label: "inst", fill: palette.purpleFill, color: palette.purple },
    { signal: "is_mul", label: "is_mul", color: palette.orange },
    { signal: "alu_a", label: "alu_a" },
    { signal: "alu_b", label: "alu_b" },
    { signal: "mul_flag", label: "mul_flag", color: palette.orange },
    { signal: "mul_div_busy", label: "mul_div_busy", color: palette.orange },
    { signal: "mul_res", label: "mul_res", fill: palette.orangeFill, color: palette.orange },
    { signal: "alu_c", label: "alu_c" },
    { signal: "rf_we", label: "rf_we", color: palette.purple },
    { signal: "rf_wD", label: "rf_wD", fill: palette.purpleFill, color: palette.purple },
    { signal: "inst_finished", label: "inst_finished", color: palette.green }
  ]
});

await writeAsset("01_singlecycle_datapath", renderSingleCycleDatapath(), 4200);
await writeAsset("02_lh_memory_waveform", lhSvg, 3600);
await writeAsset("03_mul_waveform", mulSvg, 3600);
await writeAsset("04_pipeline_datapath", renderPipelineDatapath(), 4200);
await writeAsset("05_axi_state_machine", renderAxiStateMachine(), 3800);

const hazardVcdPath = path.join(inputEvidenceDir, "06_pipeline_load_use_hazard.vcd");
const axiVcdPath = path.join(inputEvidenceDir, "06_no_cache_axi_transaction.vcd");

try {
  const hazardVcd = await parseVcd(hazardVcdPath);
  const detectedHazardStart = firstNonZero(signalChanges(hazardVcd, findSignal(hazardVcd, "load_use_hazard", "pipeline_hazard_tb.dut")));
  const memoryFreezeStart = firstNonZero(signalChanges(hazardVcd, findSignal(hazardVcd, "memory_freeze", "pipeline_hazard_tb.dut")));
  const loadRequestStart = firstNonZero(signalChanges(hazardVcd, findSignal(hazardVcd, "daccess_ren", "pipeline_hazard_tb")));
  const hazardStart = detectedHazardStart ?? memoryFreezeStart ?? loadRequestStart ?? 0;
  const responseTime = firstNonZero(signalChanges(hazardVcd, findSignal(hazardVcd, "daccess_rvalid", "pipeline_hazard_tb")));
  const responseMarkerTime = responseTime ?? Math.min(hazardVcd.lastTime, hazardStart + 100000);
  const hazardSvg = renderWaveform({
    vcd: hazardVcd,
    title: detectedHazardStart === undefined
      ? "流水线 Load-Use 测试：访存等待、气泡与恢复"
      : "流水线 Load-Use 数据冒险：暂停、气泡、访存等待与恢复",
    subtitle: detectedHazardStart === undefined
      ? "程序序列为 LW x2,0(x1) → ADDI x3,x2,1；本次波形由 memory_freeze 处理等待，load_use_hazard 保持低电平"
      : "程序序列为 LW x2,0(x1) → ADDI x3,x2,1；展示相关检测、流水级有效位和最终写回",
    startTime: Math.max(0, hazardStart - 20000),
    endTime: Math.min(hazardVcd.lastTime, responseMarkerTime + 100000),
    markers: [
      {
        time: hazardStart,
        label: detectedHazardStart === undefined ? "load request / pipeline freeze" : "load-use hazard detected",
        color: palette.red,
        fill: palette.redFill
      },
      { time: responseMarkerTime, label: "memory read response", color: palette.green, fill: palette.greenFill }
    ],
    signalSpecs: [
      { signal: "clk", label: "clk" },
      { signal: "pc", label: "pc", scope: "pipeline_hazard_tb.dut", fill: palette.purpleFill, color: palette.purple },
      { signal: "id_pc", label: "id_pc", scope: "pipeline_hazard_tb.dut" },
      { signal: "id_inst", label: "id_inst", scope: "pipeline_hazard_tb.dut", fill: palette.purpleFill, color: palette.purple },
      { signal: "ex_pc", label: "ex_pc", scope: "pipeline_hazard_tb.dut" },
      { signal: "ex_rd", label: "ex_rd", scope: "pipeline_hazard_tb.dut" },
      { signal: "load_use_hazard", label: "load_use_hazard", scope: "pipeline_hazard_tb.dut", color: palette.red },
      { signal: "stall_if", label: "stall_if", scope: "pipeline_hazard_tb.dut", color: palette.red },
      { signal: "id_valid_for_ex", label: "id_valid_for_ex", scope: "pipeline_hazard_tb.dut", color: palette.orange },
      { signal: "memory_freeze", label: "memory_freeze", scope: "pipeline_hazard_tb.dut", color: palette.orange },
      { signal: "daccess_ren", label: "daccess_ren", scope: "pipeline_hazard_tb", fill: palette.orangeFill, color: palette.orange },
      { signal: "daccess_rvalid", label: "daccess_rvalid", scope: "pipeline_hazard_tb", color: palette.green },
      { signal: "daccess_rdata", label: "daccess_rdata", scope: "pipeline_hazard_tb", fill: palette.greenFill, color: palette.green },
      { signal: "wb_rd", label: "wb_rd", scope: "pipeline_hazard_tb.dut", fill: palette.purpleFill, color: palette.purple },
      { signal: "wb_valid", label: "wb_valid", scope: "pipeline_hazard_tb.dut", color: palette.purple },
      { signal: "rf_wD", label: "rf_wD", scope: "pipeline_hazard_tb.dut", fill: palette.purpleFill, color: palette.purple }
    ]
  });
  await writeAsset("06a_pipeline_load_use_hazard", hazardSvg, 3800);
} catch (error) {
  if (error?.code !== "ENOENT") throw error;
  console.log("Optional pipeline hazard VCD not found; run miniRV_pipeline_axi_ego1/tests/generate_report_vcd.sh on Linux.");
}

try {
  const axiVcd = await parseVcd(axiVcdPath);
  const readStart = firstNonZero(signalChanges(axiVcd, findSignal(axiVcd, "ic_req", "axi_master_tb")));
  const dataReadStart = firstNonZero(signalChanges(axiVcd, findSignal(axiVcd, "dc_read", "axi_master_tb")));
  const writeStart = firstNonZero(signalChanges(axiVcd, findSignal(axiVcd, "dc_wen", "axi_master_tb")));
  const writeResponse = firstNonZero(signalChanges(axiVcd, findSignal(axiVcd, "dc_write_resp", "axi_master_tb")));
  const axiReadSvg = renderWaveform({
    vcd: axiVcd,
    title: "无 Cache 直接 AXI 读事务：AR/R 通道握手",
    subtitle: "同一波形中依次展示取指读取和数据读取；地址、VALID/READY 与返回数据均来自服务器 VCD",
    startTime: Math.max(0, readStart - 10000),
    endTime: Math.min(axiVcd.lastTime, writeStart - 5000),
    markers: [
      { time: readStart, label: "instruction read request", color: palette.blue, fill: palette.blueFill },
      { time: dataReadStart, label: "data read request", color: palette.purple, fill: palette.purpleFill }
    ],
    signalSpecs: [
      { signal: "clk", label: "clk" },
      { signal: "state", label: "dut.state", scope: "axi_master_tb.dut", fill: palette.purpleFill, color: palette.purple },
      { signal: "ic_req", label: "ic_req" },
      { signal: "dc_read", label: "dc_read" },
      { signal: "araddr", label: "ARADDR" },
      { signal: "arvalid", label: "ARVALID", color: palette.blue },
      { signal: "arready", label: "ARREADY", color: palette.blue },
      { signal: "rvalid", label: "RVALID", color: palette.blue },
      { signal: "rready", label: "RREADY", color: palette.blue },
      { signal: "rdata", label: "RDATA", fill: palette.blueFill, color: palette.blue }
    ]
  });
  await writeAsset("06b_no_cache_axi_read", axiReadSvg, 4000);

  const axiWriteSvg = renderWaveform({
    vcd: axiVcd,
    title: "无 Cache 直接 AXI 写事务：AW/W/B 通道握手",
    subtitle: "写地址和写数据通道可独立握手；两者完成后进入写响应阶段，并向 CPU 返回单周期响应",
    startTime: Math.max(0, writeStart - 10000),
    endTime: Math.min(axiVcd.lastTime, writeResponse + 10000),
    markers: [
      { time: writeStart, label: "data write request", color: palette.orange, fill: palette.orangeFill },
      { time: writeResponse, label: "B response to CPU", color: palette.green, fill: palette.greenFill }
    ],
    signalSpecs: [
      { signal: "clk", label: "clk" },
      { signal: "state", label: "dut.state", scope: "axi_master_tb.dut", fill: palette.purpleFill, color: palette.purple },
      { signal: "dc_wen", label: "dc_wen", fill: palette.orangeFill, color: palette.orange },
      { signal: "awaddr", label: "AWADDR", fill: palette.orangeFill, color: palette.orange },
      { signal: "awvalid", label: "AWVALID", color: palette.orange },
      { signal: "awready", label: "AWREADY", color: palette.orange },
      { signal: "wdata", label: "WDATA", fill: palette.orangeFill, color: palette.orange },
      { signal: "wstrb", label: "WSTRB", fill: palette.orangeFill, color: palette.orange },
      { signal: "wvalid", label: "WVALID", color: palette.orange },
      { signal: "wready", label: "WREADY", color: palette.orange },
      { signal: "bvalid", label: "BVALID", color: palette.orange },
      { signal: "bready", label: "BREADY", color: palette.orange },
      { signal: "dc_write_resp", label: "dc_write_resp", color: palette.green }
    ]
  });
  await writeAsset("06c_no_cache_axi_write", axiWriteSvg, 4000);
} catch (error) {
  if (error?.code !== "ENOENT") throw error;
  console.log("Optional AXI transaction VCD not found; run miniRV_pipeline_axi_ego1/tests/generate_report_vcd.sh on Linux.");
}
