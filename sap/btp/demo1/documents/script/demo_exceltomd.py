import json
import os
import re
import shutil
import sys
from pathlib import Path

import openpyxl


DOCUMENTS_DIR = Path(__file__).resolve().parent.parent
BK_DIR = DOCUMENTS_DIR / "bk"


# Labels that are useful for identifying common SAP interface design information.
KEY_LABELS = {
    "interface_id": ["IF ID", "IF-ID", "IF番号", "インターフェースID", "IF039"],
    "interface_name": ["IF名称", "インターフェース名称", "IF名"],
    "purpose": ["目的", "概要", "処理概要", "インターフェース概要"],
    "source": ["送信元", "送信システム", "Source", "From"],
    "target": ["送信先", "受信システム", "Target", "To"],
    "schedule": ["実行タイミング", "実行時間", "スケジュール", "周期", "タイミング"],
    "selection": ["抽出条件", "選択条件", "抽出条件等", "Selection"],
    "mapping": ["項目マッピング", "マッピング", "Mapping", "項目対応"],
    "error": ["エラー", "異常", "エラーハンドリング", "エラー処理"],
    "file": ["ファイル名", "ファイル形式", "出力ファイル", "ファイルレイアウト"],
}


def clean(value):
    if value is None:
        return ""
    value = str(value).replace("\r\n", "\n").replace("\r", "\n")
    return re.sub(r"[ \t]+", " ", value).strip()


def md_escape(value):
    value = clean(value)
    return value.replace("|", "\\|").replace("\n", "<br>")


def col_letter(n):
    result = ""
    while n:
        n, remainder = divmod(n - 1, 26)
        result = chr(65 + remainder) + result
    return result


def extract_textboxes(ws):
    # openpyxl does not expose drawing text boxes consistently.
    # Keep this hook so a future OOXML parser can add them without changing
    # the JSON/Markdown structure.
    items = []
    for shape in getattr(ws, "_charts", []):
        _ = shape
    for obj in getattr(ws, "_images", []):
        _ = obj
    return items


def parse_workbook(input_path):
    wb = openpyxl.load_workbook(input_path, data_only=False)
    result = {
        "file": input_path.name,
        "workbook": {
            "sheet_count": len(wb.worksheets),
        },
        "sheets": [],
    }

    for ws in wb.worksheets:
        cells = []
        for row in ws.iter_rows():
            for cell in row:
                if cell.value is not None:
                    cells.append(
                        {
                            "address": cell.coordinate,
                            "row": cell.row,
                            "column": cell.column,
                            "value": str(cell.value),
                        }
                    )

        result["sheets"].append(
            {
                "name": ws.title,
                "max_row": ws.max_row,
                "max_column": ws.max_column,
                "cells": cells,
                "textboxes": extract_textboxes(ws),
            }
        )

    return result


def cell_rows(sheet):
    rows = {}
    for cell in sheet["cells"]:
        rows.setdefault(cell["row"], []).append(cell)
    for row in rows.values():
        row.sort(key=lambda x: x["column"])
    return rows


def row_text(row):
    return " | ".join(clean(c["value"]) for c in row if clean(c["value"]))


def find_key_values(data):
    found = {key: [] for key in KEY_LABELS}

    for sheet in data["sheets"]:
        for row_no, row in cell_rows(sheet).items():
            text = row_text(row)
            if not text:
                continue

            for key, labels in KEY_LABELS.items():
                matched = None
                for label in labels:
                    if label.lower() in text.lower():
                        matched = label
                        break
                if matched:
                    # Prefer the value immediately following the label.
                    value = ""
                    for index, cell in enumerate(row):
                        cell_value = clean(cell["value"])
                        if matched.lower() in cell_value.lower():
                            if index + 1 < len(row):
                                value = clean(row[index + 1]["value"])
                            break
                    if not value:
                        value = text
                    found[key].append(
                        {
                            "sheet": sheet["name"],
                            "row": row_no,
                            "value": value,
                        }
                    )
    return found


def classify_sheet(sheet):
    name = clean(sheet["name"]).lower()
    text = "\n".join(clean(c["value"]) for c in sheet["cells"])

    if any(x in name for x in ["mapping", "マッピング", "項目"]):
        return "mapping"
    if any(x in name for x in ["条件", "selection", "抽出"]):
        return "selection"
    if any(x in name for x in ["エラー", "異常", "error"]):
        return "error"
    if any(x in name for x in ["概要", "基本", "interface", "if定義"]):
        return "overview"
    if "mapping" in text.lower() or "マッピング" in text:
        return "mapping"
    return "other"


def bullets_from_sheet(sheet, limit=80):
    rows = cell_rows(sheet)
    result = []
    for row_no, row in rows.items():
        text = row_text(row)
        if not text:
            continue
        result.append((row_no, text))
        if len(result) >= limit:
            break
    return result


def render_overview(data):
    kv = find_key_values(data)
    lines = ["## 1. Document Overview", ""]
    lines.append("| Item | Value |")
    lines.append("|---|---|")
    lines.append(f"| Source Excel | `{md_escape(data['file'])}` |")
    lines.append(f"| Sheet count | {data['workbook']['sheet_count']} |")

    label_map = [
        ("Interface ID", "interface_id"),
        ("Interface Name", "interface_name"),
        ("Purpose / Overview", "purpose"),
        ("Source System", "source"),
        ("Target System", "target"),
        ("Schedule", "schedule"),
    ]
    for display, key in label_map:
        values = []
        seen = set()
        for item in kv[key]:
            value = clean(item["value"])
            if value and value not in seen:
                values.append(value)
                seen.add(value)
        if values:
            lines.append(f"| {display} | {md_escape(' / '.join(values[:3]))} |")

    lines.append("")
    lines.append("> This section is automatically summarized from labeled Excel cells. The original cell data is retained in the appendix for traceability.")
    lines.append("")
    return lines


def render_section_from_key(data, title, key, max_items=30):
    kv = find_key_values(data)
    lines = [title, ""]
    items = kv.get(key, [])
    seen = set()
    count = 0
    for item in items:
        value = clean(item["value"])
        if not value or value in seen:
            continue
        seen.add(value)
        lines.append(f"- {value}  ")
        lines.append(f"  - Source: `{item['sheet']}` row {item['row']}")
        count += 1
        if count >= max_items:
            break
    if count == 0:
        lines.append("- No explicitly labeled information was detected.")
    lines.append("")
    return lines


def render_sheet_index(data):
    lines = ["## 9. Sheet Index", "", "| # | Sheet | Size | Category |", "|---:|---|---:|---|"]
    for index, sheet in enumerate(data["sheets"], 1):
        category = classify_sheet(sheet)
        size = f"{sheet['max_row']} × {sheet['max_column']}"
        lines.append(f"| {index} | {md_escape(sheet['name'])} | {size} | {category} |")
    lines.append("")
    return lines


def render_categorized_details(data):
    categories = {
        "Business / Selection Details": "selection",
        "Mapping Details": "mapping",
        "Error Handling Details": "error",
        "Other Design Details": "other",
    }
    lines = []
    number = 1
    for title, category in categories.items():
        lines.append(f"## {number}. {title}")
        lines.append("")
        matched = [s for s in data["sheets"] if classify_sheet(s) == category]
        if not matched:
            lines.append("- No dedicated sheet detected.")
            lines.append("")
            number += 1
            continue
        for sheet in matched:
            lines.append(f"### {sheet['name']}")
            lines.append("")
            for row_no, text in bullets_from_sheet(sheet):
                lines.append(f"- **Row {row_no}:** {md_escape(text)}")
            lines.append("")
        number += 1
    return lines


def render_raw_appendix(data):
    lines = ["## 13. Appendix A — Original Excel Data", ""]
    lines.append("> This appendix preserves non-empty Excel cells with coordinates so that AI-generated summaries can always be traced back to the source workbook.")
    lines.append("")

    for index, sheet in enumerate(data["sheets"], 1):
        lines.append(f"### A.{index} `{sheet['name']}`")
        lines.append("")
        lines.append(f"- Size: {sheet['max_row']} rows × {sheet['max_column']} columns")
        lines.append("")
        lines.append("| Cell | Value |")
        lines.append("|---|---|")
        for cell in sheet["cells"]:
            lines.append(f"| `{cell['address']}` | {md_escape(cell['value'])} |")
        if sheet["textboxes"]:
            for textbox in sheet["textboxes"]:
                lines.append(f"| `TEXTBOX` | {md_escape(textbox)} |")
        lines.append("")
    return lines


def json_to_markdown(data):
    title = Path(data["file"]).stem
    lines = [f"# {title}", ""]
    lines.append("> Auto-generated from the Excel design document. The Markdown is structured for both human reading and AI retrieval; the appendix preserves source-cell traceability.")
    lines.append("")

    # Machine-readable metadata block. Values are only emitted when detected.
    kv = find_key_values(data)
    metadata = {
        "source_excel": data["file"],
        "sheet_count": data["workbook"]["sheet_count"],
    }
    for key in ["interface_id", "interface_name", "source", "target"]:
        values = []
        for item in kv[key]:
            value = clean(item["value"])
            if value and value not in values:
                values.append(value)
        if values:
            metadata[key] = values[0]

    lines.append("```yaml")
    for key, value in metadata.items():
        value = str(value).replace("\n", " ").replace("\"", "\\\"")
        lines.append(f'{key}: "{value}"')
    lines.append("```")
    lines.append("")

    lines.extend(render_overview(data))
    lines.extend(render_section_from_key(data, "## 2. Purpose", "purpose"))
    lines.extend(render_section_from_key(data, "## 3. Architecture / Integration", "source"))
    lines.extend(render_section_from_key(data, "## 4. Data Selection Rules", "selection"))
    lines.extend(render_section_from_key(data, "## 5. Execution / Schedule", "schedule"))
    lines.extend(render_section_from_key(data, "## 6. Output / File Rules", "file"))
    lines.extend(render_section_from_key(data, "## 7. Mapping / Transformation", "mapping"))
    lines.extend(render_section_from_key(data, "## 8. Error Handling", "error"))
    lines.extend(render_sheet_index(data))

    # Add compact sheet-level details before the raw appendix.
    lines.extend(render_categorized_details(data))
    lines.extend(render_raw_appendix(data))

    return "\n".join(lines)


def process_file(input_path):
    input_path = Path(input_path)
    if not input_path.exists():
        raise FileNotFoundError(f"XLSX not found: {input_path}")

    BK_DIR.mkdir(parents=True, exist_ok=True)
    data = parse_workbook(input_path)

    json_path = DOCUMENTS_DIR / f"{input_path.stem}.json"
    md_path = DOCUMENTS_DIR / f"{input_path.stem}.md"

    # JSON is intentionally temporary: it is an intermediate structured representation.
    with json_path.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    md_path.write_text(json_to_markdown(data), encoding="utf-8")

    backup_path = BK_DIR / input_path.name
    if backup_path.exists():
        backup_path.unlink()
    shutil.move(str(input_path), str(backup_path))

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
