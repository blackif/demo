#!/usr/bin/env python3
"""Validate SAP ABAP README files against the repository README rules."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
TEMPLATE_DIR = ROOT / "sap" / "abap" / "documents" / "template"
LIST_TEMPLATE = TEMPLATE_DIR / "list.md"
DEMO_TEMPLATE = TEMPLATE_DIR / "demo.md"

LIST_ITEM_RE = re.compile(r"^- \[([^\]]+)\]\((\./[^)]+/)\) — (.+)$")


def fail(message: str) -> None:
    print(f"ERROR: {message}")
    raise SystemExit(1)


def get_repo_relative_path(path: str) -> Path:
    candidate = Path(path)
    if candidate.is_absolute():
        try:
            return candidate.relative_to(ROOT)
        except ValueError:
            return candidate
    return candidate


def determine_readme_type(relative_path: Path) -> str | None:
    """README depth is counted including README.md as the final level."""
    if relative_path.name != "README.md":
        return None

    parts = relative_path.parts
    if len(parts) in (3, 4):
        return "list"
    if len(parts) == 5:
        return "demo"
    return "invalid"


def read_template(path: Path) -> str:
    if not path.exists():
        fail(f"Required template does not exist: {path}")
    return path.read_text(encoding="utf-8")


def check_list_readme(relative_path: Path, lines: list[str]) -> None:
    template = read_template(LIST_TEMPLATE)
    if "List Preview" not in template:
        fail("list.md does not define the List Preview format")

    if not lines:
        fail("README.md is empty")

    folder_name = relative_path.parent.name
    expected_title = f"# {folder_name} List Preview"
    if lines[0].strip() not in (expected_title, f"{folder_name} List Preview"):
        fail(f"Invalid List README title. Expected: {expected_title}")

    if len(lines) < 2 or lines[1].strip() != "":
        fail("List README must contain exactly one blank line after the title")

    for number, line in enumerate(lines[2:], start=3):
        if not line.strip():
            fail(f"Unexpected blank line at line {number}")
        if not LIST_ITEM_RE.fullmatch(line.strip()):
            fail(
                f"Invalid List README item at line {number}. "
                "Expected: - [Folder Name](./folder/) — Description"
            )


def required_demo_headings() -> list[str]:
    template = read_template(DEMO_TEMPLATE)
    headings = []
    for line in template.splitlines():
        if line.startswith("## ") or line.startswith("### "):
            headings.append(line)
    return headings


def check_demo_readme(relative_path: Path, lines: list[str]) -> None:
    headings = required_demo_headings()
    if not lines:
        fail("README.md is empty")

    parts = relative_path.parts
    current_folder = parts[-2]
    previous_folder = parts[-3]
    expected_title = f"# {previous_folder} {current_folder}"
    if lines[0].strip() != expected_title:
        fail(f"Invalid Demo README title. Expected: {expected_title}")

    if len(lines) < 2 or lines[1].strip() != "":
        fail("Demo README must contain exactly one blank line after the title")

    content = "\n".join(lines)
    position = -1
    for heading in headings:
        try:
            current_position = content.index(heading)
        except ValueError:
            fail(f"Missing required heading: {heading}")
        if current_position <= position:
            fail(f"Heading is out of order: {heading}")
        position = current_position

    if lines[-1].strip() != "EOF":
        fail("Demo README must end with EOF")


def main() -> None:
    if len(sys.argv) < 2:
        fail("Usage: python check_readme.py <file> [<file> ...]")

    checked = False
    for raw_path in sys.argv[1:]:
        relative_path = get_repo_relative_path(raw_path)
        readme_type = determine_readme_type(relative_path)

        # Non-README files are intentionally ignored.
        if readme_type is None:
            print(f"SKIP: {raw_path} is not README.md")
            continue

        if readme_type == "invalid":
            fail(
                f"Unsupported README path depth: {relative_path}. "
                "README must be at the list or demo depth."
            )

        absolute_path = ROOT / relative_path
        if not absolute_path.exists():
            fail(f"File does not exist: {relative_path}")

        lines = absolute_path.read_text(encoding="utf-8").splitlines()
        if readme_type == "list":
            check_list_readme(relative_path, lines)
        else:
            check_demo_readme(relative_path, lines)

        print(f"PASS: {relative_path} ({readme_type} README)")
        checked = True

    if not checked:
        print("No README.md file requires validation.")


if __name__ == "__main__":
    main()
