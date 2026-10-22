#!/usr/bin/env python3
"""Write ai-curriculum sidebar (index only when no AI track pages)."""
from __future__ import annotations

import re
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
QUARTO = ROOT / "_quarto.yml"

MARK_START = "# >>> ai-curriculum-sidebar (generated — run scripts/sync-ai-sidebar.py)\n"
MARK_END = "# <<< ai-curriculum-sidebar\n"


def sidebar_contents() -> list:
    return [
        "ai-tutorials/index.qmd",
    ]


def yaml_block(data: list, indent: int = 8) -> str:
    raw = yaml.dump(
        data,
        default_flow_style=False,
        sort_keys=False,
        allow_unicode=True,
        width=120,
    )
    pad = " " * indent
    return "".join(pad + line if line.strip() else line for line in raw.splitlines(keepends=True))


def main() -> None:
    text = QUARTO.read_text()
    pattern = re.compile(
        r"      contents:\n" + re.escape(MARK_START) + r".*?" + re.escape(MARK_END),
        re.DOTALL,
    )
    replacement = (
        "      contents:\n"
        + MARK_START
        + yaml_block(sidebar_contents(), indent=8)
        + MARK_END
    )
    if not pattern.search(text):
        raise SystemExit("Could not find ai-curriculum sidebar markers in _quarto.yml")
    QUARTO.write_text(pattern.sub(replacement.rstrip() + "\n", text, count=1))
    print("Updated ai-curriculum sidebar in _quarto.yml")


if __name__ == "__main__":
    main()
