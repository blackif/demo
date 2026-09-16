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
        print(f"- ❌ FAIL: Required template does not exist: {path}")
        raise SystemExit(1)
    return path.read_text(encoding="utf-8")


def check_list_readme(relative_path: Path, lines: list[str]) -> bool:
    template = read_template(LIST_TEMPLATE)
    passed = True

    if "List Preview" not in template:
        print("- ❌ FAIL: list.md does not define the List Preview format")
        return False
    print("- ✅ PASS: 使用 sap/abap/documents/template/list.md")

    if not lines:
        print("- ❌ FAIL: README.md is empty")
        return False
    print("- ✅ PASS: README.md 非空")

    folder_name = relative_path.parent.name
    expected_title = f"# {folder_name} List Preview"
    if lines[0].strip() in (expected_title, f"{folder_name} List Preview"):
        print(f"- ✅ PASS: 标题格式正确（{expected_title}）")
    else:
        print(f"- ❌ FAIL: 标题格式错误，应为 {expected_title}")
        passed = False

    if len(lines) >= 2 and lines[1].strip() == "":
        print("- ✅ PASS: 标题后包含一个空行")
    else:
        print("- ❌ FAIL: 标题后必须包含一个空行")
        passed = False

    item_errors = []
    for number, line in enumerate(lines[2:], start=3):
        if not line.strip():
            item_errors.append(f"第 {number} 行为空行")
        elif not LIST_ITEM_RE.fullmatch(line.strip()):
            item_errors.append(f"第 {number} 行格式错误")

    if item_errors:
        for error in item_errors:
            print(f"- ❌ FAIL: List 项目 {error}，应为 - [Folder Name](./folder/) — Description")
        passed = False
    else:
        print("- ✅ PASS: 所有 List 项目格式正确")

    return passed


def required_demo_headings() -> list[str]:
    template = read_template(DEMO_TEMPLATE)
    headings = []
    for line in template.splitlines():
        if line.startswith("## ") or line.startswith("### "):
            headings.append(line)
    return headings


def check_demo_readme(relative_path: Path, lines: list[str]) -> bool:
    headings = required_demo_headings()
    passed = True

    if not lines:
        print("- ❌ FAIL: README.md is empty")
        return False
    print("- ✅ PASS: README.md 非空")

    parts = relative_path.parts
    current_folder = parts[-2]
    previous_folder = parts[-3]
    expected_title = f"# {previous_folder} {current_folder}"
    if lines[0].strip() == expected_title:
        print(f"- ✅ PASS: 标题格式正确（{expected_title}）")
    else:
        print(f"- ❌ FAIL: 标题格式错误，应为 {expected_title}")
        passed = False

    if len(lines) >= 2 and lines[1].strip() == "":
        print("- ✅ PASS: 标题后包含一个空行")
    else:
        print("- ❌ FAIL: 标题后必须包含一个空行")
        passed = False

    content = "\n".join(lines)
    position = -1
    for heading in headings:
        current_position = content.find(heading)
        if current_position == -1:
            print(f"- ❌ FAIL: 缺少必需标题 {heading}")
            passed = False
            continue
        if current_position <= position:
            print(f"- ❌ FAIL: 标题顺序错误 {heading}")
            passed = False
            continue
        print(f"- ✅ PASS: 标题存在且顺序正确 {heading}")
        position = current_position

    if lines[-1].strip() == "EOF":
        print("- ✅ PASS: README.md 以 EOF 结尾")
    else:
        print("- ❌ FAIL: README.md 必须以 EOF 结尾")
        passed = False

    return passed


def main() -> None:
    if len(sys.argv) < 2:
        print("- ❌ FAIL: Usage: python check_readme.py <file> [<file> ...]")
        raise SystemExit(1)

    checked = False
    all_passed = True
    for raw_path in sys.argv[1:]:
        relative_path = get_repo_relative_path(raw_path)
        readme_type = determine_readme_type(relative_path)

        if readme_type is None:
            print(f"- ⚪ SKIP: {raw_path} is not README.md")
            continue

        if readme_type == "invalid":
            print(f"- ❌ FAIL: README 路径层级不支持：{relative_path}")
            print("  规则：README 必须位于 List 或 Demo 层级。")
            all_passed = False
            checked = True
            continue

        absolute_path = ROOT / relative_path
        if not absolute_path.exists():
            print(f"- ❌ FAIL: 文件不存在：{relative_path}")
            all_passed = False
            checked = True
            continue

        print(f"README 检查结果：{relative_path} ({readme_type})")
        lines = absolute_path.read_text(encoding="utf-8").splitlines()
        if readme_type == "list":
            current_passed = check_list_readme(relative_path, lines)
        else:
            print("- ✅ PASS: 使用 sap/abap/documents/template/demo.md")
            current_passed = check_demo_readme(relative_path, lines)

        checked = True
        if not current_passed:
            all_passed = False

    if not checked:
        print("- ⚪ SKIP: No README.md file requires validation.")
        return

    if all_passed:
        print("- ✅ PASS: README 自动检查全部通过")
        return

    print("- ❌ FAIL: README 自动检查未通过")
    raise SystemExit(1)


if __name__ == "__main__":
    main()
