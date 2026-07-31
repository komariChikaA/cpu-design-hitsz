#!/usr/bin/env python3
"""Render report-ready engineering timing diagrams from the checked-in VCD files."""

from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from vcdvcd import VCDVCD


REPO_ROOT = Path(__file__).resolve().parents[2]
VCD_DIR = REPO_ROOT / "docs" / "course-report" / "vcd"
FIGURE_DIR = REPO_ROOT / "docs" / "course-report" / "figures"


def signal(vcd: VCDVCD, name: str):
    return vcd[name].tv


def value_at(tv, t):
    value = tv[0][1]
    for change_t, change_value in tv:
        if change_t > t:
            break
        value = change_value
    return value


def transitions(tv, start, end):
    points = [(start, value_at(tv, start))]
    points.extend((t, value) for t, value in tv if start < t < end)
    points.append((end, value_at(tv, end)))
    return points


def logic_value(value: str) -> float:
    if value == "1":
        return 0.78
    if value == "0":
        return 0.16
    return 0.47


def draw_scalar(ax, row, tv, start, end, label, color="#145a86"):
    pts = transitions(tv, start, end)
    xs = [t / 1000 for t, _ in pts]
    ys = [row + logic_value(v) for _, v in pts]
    ax.step(xs, ys, where="post", color=color, linewidth=1.8)
    ax.text(start / 1000 - 2.1, row + 0.47, label, ha="right", va="center",
            fontfamily="DejaVu Sans Mono", fontsize=10.5, color="#101820")


def format_bus(value: str, width: int, state_names=None):
    if not value or any(ch in value.lower() for ch in "xz"):
        return "X"
    number = int(value, 2)
    if state_names is not None:
        return state_names.get(number, str(number))
    digits = max(1, (width + 3) // 4)
    return f"{number:0{digits}X}"


def draw_bus(ax, row, tv, start, end, label, width, state_names=None,
             color="#40566b", fill="#edf3f7"):
    pts = transitions(tv, start, end)
    for index in range(len(pts) - 1):
        t0, value = pts[index]
        t1, _ = pts[index + 1]
        x0, x1 = t0 / 1000, t1 / 1000
        box = FancyBboxPatch(
            (x0, row + 0.13),
            max(x1 - x0, 0.02),
            0.68,
            boxstyle="round,pad=0.015,rounding_size=0.06",
            linewidth=1.05,
            edgecolor=color,
            facecolor=fill,
        )
        ax.add_patch(box)
        text = format_bus(value, width, state_names)
        if x1 - x0 >= 4.5:
            ax.text((x0 + x1) / 2, row + 0.47, text, ha="center", va="center",
                    fontfamily="DejaVu Sans Mono", fontsize=9.2, color="#101820")
    ax.text(start / 1000 - 2.1, row + 0.47, label, ha="right", va="center",
            fontfamily="DejaVu Sans Mono", fontsize=10.5, color="#101820")


def finish_axes(ax, start, end, rows, title, subtitle):
    ax.set_xlim(start / 1000 - 17, end / 1000 + 1)
    ax.set_ylim(0, rows + 0.2)
    ax.set_yticks([])
    ax.set_xlabel("仿真时间 / ns", fontfamily="Microsoft YaHei", fontsize=10.5)
    ax.set_title(title, loc="left", fontfamily="Microsoft YaHei",
                 fontsize=15, fontweight="bold", pad=20)
    ax.text(0.0, 1.01, subtitle, transform=ax.transAxes, ha="left", va="bottom",
            fontfamily="Microsoft YaHei", fontsize=10.2, color="#40566b")
    ax.grid(axis="x", color="#c9d3dc", linewidth=0.7, linestyle="--", alpha=0.9)
    ax.spines[["top", "right", "left"]].set_visible(False)
    ax.spines["bottom"].set_color("#62798b")
    ax.tick_params(axis="x", labelsize=9.5, colors="#334a5b")


def save_figure(fig, stem):
    FIGURE_DIR.mkdir(parents=True, exist_ok=True)
    png = FIGURE_DIR / f"{stem}.png"
    svg = FIGURE_DIR / f"{stem}.svg"
    fig.savefig(png, dpi=220, bbox_inches="tight", facecolor="white")
    fig.savefig(svg, bbox_inches="tight", facecolor="white")
    # Matplotlib writes trailing spaces in multiline SVG path data.  Strip
    # them so regenerated assets remain friendly to `git diff --check`.
    svg_text = svg.read_text(encoding="utf-8")
    svg.write_text(
        "\n".join(line.rstrip() for line in svg_text.splitlines()) + "\n",
        encoding="utf-8",
    )
    plt.close(fig)
    print(png)
    print(svg)


def render_cache_refill():
    vcd = VCDVCD(str(VCD_DIR / "10_cache_refill_hit_uncached.vcd"), store_tvs=True)
    start, end = 25000, 75000
    fig, ax = plt.subplots(figsize=(13.2, 7.2))

    draw_scalar(ax, 8, signal(vcd, "cache_tb.ic_cpu_ren"), start, end, "cpu_ren")
    draw_bus(ax, 7, signal(vcd, "cache_tb.ic_cpu_addr[31:0]"), start, end,
             "cpu_addr", 32)
    draw_bus(
        ax, 6, signal(vcd, "cache_tb.U_icache.state[1:0]"), start, end,
        "ICache state", 2, {0: "IDLE", 1: "LOOKUP", 2: "REFILL"}
    )
    draw_scalar(ax, 5, signal(vcd, "cache_tb.U_icache.cpu_hit"), start, end,
                "cpu_hit", "#1d7a45")
    draw_scalar(ax, 4, signal(vcd, "cache_tb.ic_dev_ren"), start, end,
                "dev_ren", "#9c4c14")
    draw_bus(ax, 3, signal(vcd, "cache_tb.ic_dev_addr[31:0]"), start, end,
             "line_addr", 32, color="#9c4c14", fill="#fff3e7")
    draw_scalar(ax, 2, signal(vcd, "cache_tb.ic_dev_valid"), start, end,
                "dev_rvalid", "#9c4c14")
    draw_scalar(ax, 1, signal(vcd, "cache_tb.ic_cpu_valid"), start, end,
                "cpu_rvalid", "#1d7a45")
    draw_bus(ax, 0, signal(vcd, "cache_tb.ic_cpu_data[31:0]"), start, end,
             "cpu_rdata", 32, color="#1d7a45", fill="#eaf6ef")

    ax.axvline(35, color="#9c4c14", linewidth=1.1)
    ax.text(35.5, 9.0, "miss，地址对齐到 0x20", fontsize=9.4,
            fontfamily="Microsoft YaHei", color="#7d3b10")
    ax.axvline(50, color="#9c4c14", linewidth=1.1)
    ax.text(50.5, 8.55, "128-bit line 返回", fontsize=9.4,
            fontfamily="Microsoft YaHei", color="#7d3b10")
    ax.axvline(55, color="#1d7a45", linewidth=1.1)
    ax.text(55.5, 8.1, "写 tag/data/valid，并向 CPU 返回目标 word", fontsize=9.4,
            fontfamily="Microsoft YaHei", color="#145c35")

    finish_axes(
        ax, start, end, 9,
        "ICache miss、整行回填与随后命中",
        "来源：10_cache_refill_hit_uncached.vcd；CPU 地址 0x24 所在线为 0x20～0x2F。",
    )
    fig.tight_layout()
    save_figure(fig, "07_cache_refill_hit")


def render_axi_burst():
    vcd = VCDVCD(str(VCD_DIR / "08_axi_cacheline_burst.vcd"), store_tvs=True)
    start, end = 30000, 122000
    fig, ax = plt.subplots(figsize=(13.2, 7.5))

    draw_scalar(ax, 9, signal(vcd, "axi_master_tb.ic_req"), start, end,
                "ic_req")
    draw_bus(ax, 8, signal(vcd, "axi_master_tb.araddr[31:0]"), start, end,
             "ARADDR", 32)
    draw_bus(ax, 7, signal(vcd, "axi_master_tb.arlen[7:0]"), start, end,
             "ARLEN", 8)
    draw_scalar(ax, 6, signal(vcd, "axi_master_tb.arvalid"), start, end,
                "ARVALID")
    draw_scalar(ax, 5, signal(vcd, "axi_master_tb.arready"), start, end,
                "ARREADY", "#1d7a45")
    draw_scalar(ax, 4, signal(vcd, "axi_master_tb.rvalid"), start, end,
                "RVALID", "#9c4c14")
    draw_scalar(ax, 3, signal(vcd, "axi_master_tb.rready"), start, end,
                "RREADY", "#1d7a45")
    draw_bus(ax, 2, signal(vcd, "axi_master_tb.rdata[31:0]"), start, end,
             "RDATA", 32, color="#9c4c14", fill="#fff3e7")
    draw_scalar(ax, 1, signal(vcd, "axi_master_tb.rlast"), start, end,
                "RLAST", "#9c4c14")
    draw_scalar(ax, 0, signal(vcd, "axi_master_tb.ic_valid"), start, end,
                "line_valid", "#1d7a45")

    for x, text in [
        (65, "AR 握手"),
        (75, "beat 0"),
        (86, "beat 1"),
        (96, "beat 2"),
        (106, "beat 3 + RLAST"),
        (115, "整行提交"),
    ]:
        ax.axvline(x, color="#62798b", linewidth=0.85, linestyle=":")
        ax.text(x + 0.4, 10.1, text, rotation=25, ha="left", va="bottom",
                fontsize=8.8, fontfamily="Microsoft YaHei", color="#334a5b")

    finish_axes(
        ax, start, end, 10,
        "AXI 四拍 Cache Line refill",
        "ARLEN=3 表示 4 个 32-bit beat；仅在 VALID && READY 同时为 1 的时钟沿完成传输。",
    )
    fig.tight_layout()
    save_figure(fig, "08_axi_cacheline_burst")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--only", choices=["cache", "axi", "all"], default="all")
    args = parser.parse_args()
    if args.only in ("cache", "all"):
        render_cache_refill()
    if args.only in ("axi", "all"):
        render_axi_burst()


if __name__ == "__main__":
    main()
