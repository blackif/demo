import json
import os
import shutil
import sys
from pathlib import Path

import openpyxl


DOCUMENTS_DIR = Path(__file__).resolve().parent.parent
BK_DIR = DOCUMENTS_DIR / "bk"


def col_letter(n):
    result = ""
    while n:
        n, remainder = divmod(n - 1, 26)
        result = chr(65 + remainder) + result
    return result


def extract_textboxes(ws):
    items = []
    for shape in getattr(ws, "_charts", []):
        _ = shape
    for obj in getattr(ws, "_images", []):
        _ = obj

    # openpyxl does not expose drawing text boxes consistently.
    # Preserve this hook so the parser can be extended without changing the workflow.
    return items


def parse_workbook(input_path):
    wb = openpyxl.load_workbook(input_path, data_only=False)
    result = {"file": input_path.name, "sheets": []}

    for ws in wb.worksheets:
        sheet = {
            "name": ws.title,
            "max_row": ws.max_row,
            "max_column": ws.max_column,
            "cells": [],
            "textboxes": extract_textboxes(ws),
        }

        for row in ws.iter_rows():
            for cell in row:
                if cell.value is not None:
                    sheet["cells"].append({
                        "address": cell.coordinate,
                        "row": cell.row,
                        "column": cell.column,
                        "value": str(cell.value),
                    })

        result["sheets"].append(sheet)

    return result


def json_to_markdown(data):
    lines = [f"# {Path(data['file']).stem}", ""]
    lines.append(f"- Source: `{data['file']}`")
    lines.append(f"- Sheets: {len(data['sheets'])}")
    lines.append("")

    for index, sheet in enumerate(data["sheets"], 1):
        lines.append(f"## {index}. {sheet['name']}")
        lines.append("")
        lines.append(f"- Size: {sheet['max_row']} rows × {sheet['max_column']} columns")
        lines.append("")

        if sheet["cells"]:
            lines.append("### Cells")
            lines.append("")
            lines.append("| Cell | Value |")
            lines.append("|---|---|")
            for cell in sheet["cells"]:
                value = cell["value"].replace("|", "\\|").replace("\n", "<br>")
                lines.append(f"| `{cell['address']}` | {value} |")
            lines.append("")

        if sheet["textboxes"]:
            lines.append("### Text Boxes")
            lines.append("")
            for textbox in sheet["textboxes"]:
                lines.append(f"- {textbox}")
            lines.append("")

    return "\n".join(lines)


def process_file(input_path):
    input_path = Path(input_path)
    BK_DIR.mkdir(parents=True, exist_ok=True)

    data = parse_workbook(input_path)

    json_path = DOCUMENTS_DIR / f"{input_path.stem}.json"
    md_path = DOCUMENTS_DIR / f"{input_path.stem}.md"

    with json_path.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    md_path.write_text(json_to_markdown(data), encoding="utf-8")

    backup_path = BK_DIR / input_path.name
    if backup_path.exists():
        backup_path.unlink()
    shutil.move(str(input_path), str(backup_path))

    # JSON is an intermediate artifact; keep only the Markdown in documents/.
    if json_path.exists():
        json_path.unlink()

    print(f"Processed: {input_path.name}")
    print(f"Markdown: {md_path}")
    print(f"Backup:   {backup_path}")


def main():
    if len(sys.argv) > 1:
        files = [Path(arg) for arg in sys.argv[1:]]
    else:
        files = sorted(DOCUMENTS_DIR.glob("*.xlsx"))

    if not files:
        print("No XLSX files found.")
        return

    for file_path in files:
        process_file(file_path)


if __name__ == "__main__":
    main()
