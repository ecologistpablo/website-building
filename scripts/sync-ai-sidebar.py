#!/usr/bin/env python3
"""Merge ai-tutorials/_quest-links.yml files into _quarto.yml sidebar contents."""
from __future__ import annotations

import re
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
QUARTO = ROOT / "_quarto.yml"

TRACKS = [
    ("Beginner · Base R", ROOT / "ai-tutorials/level-1-base-r/_quest-links.yml"),
    ("Intermediate · dplyr", ROOT / "ai-tutorials/level-2-dplyr/_quest-links.yml"),
    ("Intermediate · purrr & furrr", ROOT / "ai-tutorials/level-3-purrr/_quest-links.yml"),
    ("Advanced · data.table", ROOT / "ai-tutorials/level-4-data-table/_quest-links.yml"),
]
CS = ROOT / "ai-tutorials/cs-crash-course/_quest-links.yml"

MARK_START = "# >>> ai-curriculum-sidebar (generated — run scripts/sync-ai-sidebar.py)\n"
MARK_END = "# <<< ai-curriculum-sidebar\n"


def track_section(title: str, yml_path: Path) -> dict:
    items = yaml.safe_load(yml_path.read_text())
    index_href = items[0] if isinstance(items[0], str) else items[0]["href"]
    contents = items[1:] if isinstance(items[0], str) and items[0] == index_href else items
    return {"section": title, "href": index_href, "contents": contents}


def sidebar_contents() -> list:
    fp_tracks = [track_section(name, path) for name, path in TRACKS]
    cs_items = yaml.safe_load(CS.read_text())
    cs_href = cs_items[0] if isinstance(cs_items[0], str) else cs_items[0]["href"]
    cs_contents = (
        cs_items[1:] if isinstance(cs_items[0], str) and cs_items[0] == cs_href else cs_items
    )
    return [
        "ai-tutorials/index.qmd",
        {"section": "Functional programming", "contents": fp_tracks},
        {
            "section": "Computer science crash course",
            "href": cs_href,
            "contents": cs_contents,
        },
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
