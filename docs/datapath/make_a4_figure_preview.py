#!/usr/bin/env python3
"""Create A4-landscape QA pages at the same figure width used in the DOCX."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

REPO_ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = REPO_ROOT / "docs" / "course-report" / "figures"
OUTPUT = REPO_ROOT / "outputs" / "report" / "qa" / "figures-final-v2"

PAGE = (1754, 1240)  # A4 landscape at 150 dpi
FIGURE_WIDTH = 1530  # 10.2 inches at 150 dpi, same as the DOCX builder
TOP = 58
CAPTION_Y = 1135

FIGURES = [
    ("01_singlecycle_datapath.png", "图 1-1  miniRV 普通单周期 CPU 数据通路总图"),
    ("04_pipeline_datapath.png", "图 2-1  miniRV 五级流水线 CPU 数据通路总图"),
    ("05_axi_state_machine.png", "图 2-2  无 Cache 的 AXI4 单事务主机状态转换图"),
    (
        "06a_pipeline_load_use_hazard.png",
        "图 2-3  流水线 Load-Use 测试中的访存等待、气泡与恢复波形",
    ),
    (
        "06b_no_cache_axi_read.png",
        "图 2-4  无 Cache 的 AXI 读事务及 AR/R 通道握手波形",
    ),
    (
        "06c_no_cache_axi_write.png",
        "图 2-5  无 Cache 的 AXI 写事务及 AW/W/B 通道握手波形",
    ),
]


def font(size: int):
    candidates = [
        Path("C:/Windows/Fonts/msyh.ttc"),
        Path("C:/Windows/Fonts/simhei.ttf"),
        Path("C:/Windows/Fonts/arial.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default()


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    pages = []
    for index, (filename, caption) in enumerate(FIGURES, start=1):
        source = Image.open(EVIDENCE / filename).convert("RGB")
        scale = min(FIGURE_WIDTH / source.width, 1040 / source.height)
        resized = source.resize(
            (round(source.width * scale), round(source.height * scale)),
            Image.Resampling.LANCZOS,
        )
        page = Image.new("RGB", PAGE, "white")
        x = (PAGE[0] - resized.width) // 2
        page.paste(resized, (x, TOP))
        draw = ImageDraw.Draw(page)
        caption_font = font(26)
        box = draw.textbbox((0, 0), caption, font=caption_font)
        caption_y = min(CAPTION_Y, TOP + resized.height + 24)
        draw.text(
            ((PAGE[0] - (box[2] - box[0])) // 2, caption_y),
            caption,
            fill="#111827",
            font=caption_font,
        )
        output_png = OUTPUT / f"a4-figure-{index}.png"
        page.save(output_png, dpi=(150, 150))
        pages.append(page)
        print(output_png)

    pages[0].save(
        OUTPUT / "a4-figure-preview.pdf",
        "PDF",
        resolution=150,
        save_all=True,
        append_images=pages[1:],
    )


if __name__ == "__main__":
    main()
