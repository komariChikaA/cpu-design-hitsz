import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { Resvg } from "@resvg/resvg-js";

const here = path.dirname(fileURLToPath(import.meta.url));
const targets = [
  { name: "system", width: 1920 },
  { name: "core", width: 4800 },
  { name: "compact", width: 3600 }
];

for (const target of targets) {
  const svg = await fs.readFile(path.join(here, `${target.name}.svg`), "utf8");
  const renderer = new Resvg(svg, {
    fitTo: { mode: "width", value: target.width },
    font: { loadSystemFonts: true },
    background: "#ffffff"
  });
  const png = renderer.render().asPng();
  const output = path.join(here, `${target.name}.png`);
  await fs.writeFile(output, png);
  console.log(`${path.relative(process.cwd(), output)}: ${target.width}px wide, ${png.length} bytes`);
}
