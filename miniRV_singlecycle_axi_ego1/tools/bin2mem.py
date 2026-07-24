#!/usr/bin/env python3
"""Convert a little-endian RISC-V .bin or Vivado .coe file to readmemh."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def read_bin(path: Path) -> list[int]:
    data = path.read_bytes()
    if len(data) % 4:
        data += bytes(4 - len(data) % 4)
    return [int.from_bytes(data[i : i + 4], "little") for i in range(0, len(data), 4)]


def read_coe(path: Path) -> list[int]:
    text = path.read_text(encoding="utf-8-sig")
    radix_match = re.search(r"MEMORY_INITIALIZATION_RADIX\s*=\s*(\d+)\s*;", text, re.I)
    vector_match = re.search(
        r"MEMORY_INITIALIZATION_VECTOR\s*=\s*(.*?)(?:\s*;\s*$|\s*$)",
        text,
        re.I | re.S,
    )
    if not radix_match or not vector_match:
        raise ValueError("input is not a supported Vivado COE file")
    radix = int(radix_match.group(1))
    if radix not in (2, 10, 16):
        raise ValueError(f"unsupported COE radix: {radix}")
    tokens = [token for token in re.split(r"[\s,]+", vector_match.group(1)) if token]
    return [int(token, radix) for token in tokens]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path, help="little-endian .bin or Vivado .coe")
    parser.add_argument("output", type=Path, help="readmemh output file")
    parser.add_argument("--depth", type=int, default=38_400, help="32-bit word count")
    args = parser.parse_args()

    words = read_coe(args.input) if args.input.suffix.lower() == ".coe" else read_bin(args.input)
    if len(words) > args.depth:
        raise SystemExit(f"program has {len(words)} words, memory holds {args.depth}")
    if any(word < 0 or word > 0xFFFF_FFFF for word in words):
        raise SystemExit("input contains a value wider than 32 bits")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    padded = words + [0] * (args.depth - len(words))
    args.output.write_text("".join(f"{word:08x}\n" for word in padded), encoding="ascii")
    print(f"wrote {len(words)} program words and {args.depth - len(words)} padding words")


if __name__ == "__main__":
    main()
