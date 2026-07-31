#!/usr/bin/env python3
"""Build the offline HTML/PDF self-study manual from the checked-in Markdown.

The HTML stays searchable and easy to navigate during study.  The PDF is the
fixed-layout copy for offline reading and printing.  Both use the same source
of truth: docs/acceptance/COREMARK_PIPELINE_AXI_STUDY_GUIDE.md.
"""

from __future__ import annotations

import argparse
import html
import os
import re
import subprocess
from pathlib import Path

import markdown


FIGURE_INSERTS = {
    "## 1. 先建立完整层级": """

<figure>
  <img src="../course-report/figures/04_pipeline_datapath.png"
       alt="最终流水线 CPU 数据通路">
  <figcaption>图 1　最终流水线 CPU 数据通路。阅读时按 IF → ID → EX → MEM → WB 追踪；橙色回路是前递和控制回送。</figcaption>
</figure>
""",
    "## 5.2 Load-use": """

<figure>
  <img src="../course-report/figures/06a_pipeline_load_use_hazard.png"
       alt="load-use 冒险波形">
  <figcaption>图 2　load-use 定向波形。现场必须结合 valid、目的/源寄存器、stall 与返回数据解释，不能只看 PC 残值。</figcaption>
</figure>
""",
    "## 9. AXI Master 五通道": """

<figure>
  <img src="../course-report/figures/05_axi_state_machine.png"
       alt="AXI Master 状态机">
  <figcaption>图 3　AXI Master 状态机。读事务由 AR/R 完成，写事务由 AW/W/B 完成。</figcaption>
</figure>
""",
    "## 9.1 读事务": """

<figure>
  <img src="../course-report/figures/06b_no_cache_axi_read.png"
       alt="AXI 读通道波形">
  <figcaption>图 4　AXI 读通道。只有 VALID 与 READY 同时为 1 的上升沿才完成一次传输。</figcaption>
</figure>
""",
    "## 9.2 写事务": """

<figure>
  <img src="../course-report/figures/06c_no_cache_axi_write.png"
       alt="AXI 写通道波形">
  <figcaption>图 5　AXI 写通道。AW 与 W 独立握手，二者完成后再等待 B 响应。</figcaption>
</figure>
""",
}


CSS = r"""
:root {
  --ink: #111317;
  --muted: #58616d;
  --rule: #b8bec7;
  --panel: #f1f3f5;
  --panel-2: #fafafa;
  --accent: #d94f00;
  --accent-soft: #fff0e6;
  --blue: #155e9a;
}

* { box-sizing: border-box; }

html {
  scroll-behavior: smooth;
  background: #e9ecef;
}

body {
  margin: 0;
  color: var(--ink);
  font-family: "Microsoft YaHei", "Noto Sans CJK SC", sans-serif;
  font-size: 18px;
  line-height: 1.72;
}

.shell {
  display: grid;
  grid-template-columns: 320px minmax(0, 1fr);
  max-width: 1500px;
  margin: 0 auto;
  background: white;
  min-height: 100vh;
}

nav {
  position: sticky;
  top: 0;
  height: 100vh;
  overflow-y: auto;
  padding: 30px 26px;
  background: #171a1f;
  color: white;
}

nav .brand {
  color: #ff7a33;
  font-family: Consolas, monospace;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: .05em;
  margin-bottom: 14px;
}

nav .nav-title {
  font-size: 24px;
  font-weight: 700;
  line-height: 1.35;
  margin-bottom: 26px;
}

nav a {
  display: block;
  padding: 7px 0;
  color: #d8dde5;
  text-decoration: none;
  font-size: 14px;
  line-height: 1.35;
}

nav a:hover { color: #ff7a33; }
nav ul { padding-left: 18px; margin: 0; }
nav li::marker { color: #747d89; }
nav > ul > li > a { color: white; font-weight: 700; margin-top: 8px; }

main {
  min-width: 0;
  max-width: 1060px;
  padding: 58px 74px 100px;
}

.cover {
  min-height: 650px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  border-bottom: 5px solid var(--ink);
  margin-bottom: 60px;
}

.eyebrow {
  color: var(--accent);
  font: 700 15px/1.3 Consolas, monospace;
  letter-spacing: .05em;
}

.cover h1 {
  margin: 28px 0 24px;
  max-width: 900px;
  font-size: 54px;
  line-height: 1.18;
  letter-spacing: -.035em;
}

.cover p {
  max-width: 820px;
  font-size: 24px;
  line-height: 1.6;
  color: var(--muted);
}

.cover .scope {
  margin-top: 50px;
  padding-top: 22px;
  border-top: 1px solid var(--rule);
  font: 700 16px/1.5 Consolas, monospace;
  color: var(--ink);
}

h1, h2, h3, h4 {
  color: var(--ink);
  line-height: 1.28;
  page-break-after: avoid;
}

main > h1 { display: none; }

h2 {
  margin: 82px 0 28px;
  padding-top: 20px;
  border-top: 4px solid var(--ink);
  font-size: 34px;
  letter-spacing: -.02em;
}

h3 {
  margin: 48px 0 18px;
  padding-left: 16px;
  border-left: 6px solid var(--accent);
  font-size: 27px;
}

h4 {
  margin: 34px 0 14px;
  font-size: 22px;
}

p { margin: 14px 0; }

blockquote {
  margin: 26px 0;
  padding: 20px 26px;
  border-left: 7px solid var(--accent);
  background: var(--accent-soft);
  color: var(--ink);
  page-break-inside: avoid;
}

blockquote p { margin: 5px 0; }

code {
  padding: .08em .32em;
  background: #eef0f2;
  color: #9c3300;
  font-family: Consolas, "Cascadia Mono", monospace;
  font-size: .92em;
}

pre {
  margin: 22px 0 28px;
  padding: 22px 26px;
  overflow-x: auto;
  border-left: 6px solid var(--accent);
  background: #171a1f;
  color: #f5f7fa;
  font: 15px/1.58 Consolas, "Cascadia Mono", monospace;
  page-break-inside: avoid;
}

pre code {
  padding: 0;
  background: transparent;
  color: inherit;
  font-size: inherit;
}

table {
  width: 100%;
  margin: 24px 0 34px;
  border-collapse: collapse;
  font-size: 16px;
  page-break-inside: avoid;
}

thead { display: table-header-group; }

th {
  padding: 12px 14px;
  border: 1px solid #89929d;
  background: #e3e6e9;
  text-align: left;
  font-weight: 700;
}

td {
  padding: 11px 14px;
  border: 1px solid #b8bec7;
  vertical-align: top;
}

tr:nth-child(even) td { background: #fafafa; }

ul, ol { padding-left: 1.6em; }
li { margin: 7px 0; }
li::marker { color: var(--accent); font-weight: 700; }

figure {
  margin: 32px 0 42px;
  padding: 20px;
  border: 1px solid var(--rule);
  background: var(--panel-2);
  page-break-inside: avoid;
}

figure img {
  display: block;
  width: 100%;
  max-height: 700px;
  object-fit: contain;
}

figcaption {
  margin-top: 14px;
  color: var(--muted);
  font-size: 15px;
  line-height: 1.55;
}

.print-meta {
  margin: 30px 0 50px;
  padding: 18px 22px;
  background: var(--panel);
  border-left: 6px solid var(--blue);
  font-size: 15px;
  color: var(--muted);
}

@media (max-width: 1000px) {
  .shell { display: block; }
  nav { position: relative; width: 100%; height: auto; }
  main { padding: 40px 28px 80px; }
  .cover h1 { font-size: 40px; }
}

@page {
  size: A4;
  margin: 17mm 16mm 18mm;
  @bottom-right {
    content: counter(page);
    color: #666;
    font: 9pt Consolas, monospace;
  }
}

@media print {
  html, body { background: white; }
  body { font-size: 12pt; line-height: 1.62; }
  .shell { display: block; max-width: none; }
  nav { display: none; }
  main { max-width: none; padding: 0; }
  .cover {
    min-height: 240mm;
    page-break-after: always;
    margin: 0;
  }
  .cover h1 { font-size: 34pt; }
  .cover p { font-size: 17pt; }
  h2 {
    margin-top: 0;
    padding-top: 0;
    font-size: 23pt;
    break-before: page;
  }
  h3 { font-size: 18pt; }
  h4 { font-size: 15pt; }
  pre { font-size: 9.2pt; white-space: pre-wrap; overflow: visible; }
  table { font-size: 9.6pt; }
  figure img { max-height: 220mm; }
  a { color: inherit; text-decoration: none; }
  .cache-vcd-page-break { break-before: page; }
}
"""


def add_figures(source: str) -> str:
    for heading, figure in FIGURE_INSERTS.items():
        source = source.replace(heading, heading + figure, 1)
    source = source.replace(
        "<!-- PDF_BREAK_CACHE_VCD -->",
        '<div class="cache-vcd-page-break"></div>',
        1,
    )
    return source


def rebase_local_urls(fragment: str, source_dir: Path, output_dir: Path) -> str:
    """Keep Markdown-relative links valid after writing HTML one directory deeper."""

    pattern = re.compile(
        r'(?P<prefix>\b(?:href|src)=["\'])(?P<url>[^"\']+)(?P<suffix>["\'])'
    )

    def replace(match: re.Match[str]) -> str:
        url = match.group("url")
        if url.startswith(("#", "/", "http:", "https:", "data:", "mailto:", "javascript:")):
            return match.group(0)

        path_and_query, marker, fragment_id = url.partition("#")
        path_only, query_marker, query = path_and_query.partition("?")
        if not path_only:
            return match.group(0)

        target = (source_dir / path_only).resolve()
        relative = os.path.relpath(target, output_dir).replace(os.sep, "/")
        rebased = relative
        if query_marker:
            rebased += "?" + query
        if marker:
            rebased += "#" + fragment_id
        return match.group("prefix") + rebased + match.group("suffix")

    return pattern.sub(replace, fragment)


def build_html(markdown_path: Path, html_path: Path) -> None:
    source = add_figures(markdown_path.read_text(encoding="utf-8"))
    converter = markdown.Markdown(
        extensions=[
            "fenced_code",
            "tables",
            "toc",
            "sane_lists",
        ],
        extension_configs={"toc": {"permalink": False, "toc_depth": "2-3"}},
    )
    body = converter.convert(source)
    body = rebase_local_urls(body, markdown_path.parent, html_path.parent)
    toc = converter.toc

    document = f"""<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>miniRV 流水线 AXI CoreMark 代码与波形自学手册</title>
  <style>{CSS}</style>
</head>
<body>
  <div class="shell">
    <nav>
      <div class="brand">MINIRV / RV32IM / AXI4</div>
      <div class="nav-title">代码与波形<br>自学手册</div>
      {toc}
    </nav>
    <main>
      <section class="cover">
        <div class="eyebrow">FINAL COREMARK PIPELINE AXI IMPLEMENTATION</div>
        <h1>流水线 AXI CoreMark<br>代码理解与波形验收手册</h1>
        <p>把 CPU 五段、冒险、AXI 五通道和板级外设落实到具体文件、代码条件与现场波形。目标是能够独立沿时钟解释，而不是背答案。</p>
        <div class="scope">唯一学习对象：miniRV_pipeline_axi_ego1/</div>
      </section>
      <div class="print-meta">
        本手册由仓库内 Markdown 生成。代码位置以当前分支为准；现场回答时应直接打开对应 RTL，并以 valid + 时钟沿确认指令是否有效。
      </div>
      {body}
    </main>
  </div>
</body>
</html>
"""
    html_path.parent.mkdir(parents=True, exist_ok=True)
    html_path.write_text(document, encoding="utf-8")


def chrome_print(chrome: Path, html_path: Path, pdf_path: Path) -> None:
    pdf_path.parent.mkdir(parents=True, exist_ok=True)
    command = [
        str(chrome),
        "--headless=new",
        "--disable-gpu",
        "--no-pdf-header-footer",
        "--allow-file-access-from-files",
        f"--print-to-pdf={pdf_path}",
        html_path.resolve().as_uri(),
    ]
    result = subprocess.run(
        command,
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if result.returncode != 0 or not pdf_path.exists():
        raise RuntimeError(
            "Chrome PDF export failed\n"
            + (result.stdout or "")
            + (result.stderr or "")
        )


def find_chrome(explicit: str | None) -> Path:
    candidates = [
        Path(explicit) if explicit else None,
        Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe"),
        Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
    ]
    for candidate in candidates:
        if candidate and candidate.exists():
            return candidate
    raise FileNotFoundError("Chrome/Edge executable not found")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument("--chrome")
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    source = repo_root / "docs" / "acceptance" / "COREMARK_PIPELINE_AXI_STUDY_GUIDE.md"
    output_dir = repo_root / "docs" / "acceptance" / "training"
    html_path = output_dir / "miniRV_CoreMark流水线AXI_代码与波形自学手册.html"
    pdf_path = output_dir / "miniRV_CoreMark流水线AXI_代码与波形自学手册.pdf"

    if not source.exists():
        raise FileNotFoundError(source)
    build_html(source, html_path)
    chrome_print(find_chrome(args.chrome), html_path, pdf_path)
    print(html_path)
    print(pdf_path)


if __name__ == "__main__":
    main()
