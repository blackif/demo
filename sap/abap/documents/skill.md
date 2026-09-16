# SAP ABAP README Creation Skill

## Purpose

This skill defines the standard procedure for creating or updating README files under `sap/abap/` so that documentation format remains consistent across the repository.

## Execution Rules

AI must execute the following steps in order whenever it creates or modifies a README file.

### 1. Determine README Type

First determine whether the target README is a **list README** or a **demo README** from its repository-relative path depth.

- **List README**: the README is located at the third or fourth path level.
  - Example: `sap/abap/README.md`
  - Example: `sap/abap/rap/README.md`
  - Example: `sap/abap/Classical/README.md`
- **Demo README**: the README is located at the fifth path level.
  - Example: `sap/abap/Classical/demo1/README.md`

The path level must be determined from the repository-relative path, not from the local filesystem path.

### 2. Check and Apply the Correct Template

Before editing the README, AI must check the corresponding template under:

`sap/abap/documents/template/`

- List README → `sap/abap/documents/template/list.md`
- Demo README → `sap/abap/documents/template/demo.md`

The README must strictly follow the corresponding template's structure and formatting.

If the required template file does not exist, **stop the remaining steps** and inform the user that the corresponding template is missing. Do not create or modify the target README based on an assumed format.

#### List README Rules

The first line must be the current folder/file name followed by `List Preview`.

Example:

```text
ABAP List Preview
```

Then leave exactly one blank line. Starting from the third line, list the child folder links and their descriptions.

Example:

```text
- [Demo1](./demo1/) — Manufacturing Order Header OData V4 Web API
- [Demo2](./demo2/) — Manufacturing Order Component OData V4 Web API
```

There must be no additional blank lines between list items.

#### Demo README Rules

The first line must be the current folder name followed by the current folder name in the form `[Type] [FolderName]`.

Example:

```text
RAP Demo1
```

Then leave exactly one blank line and use the following fixed section order:

1. `処理概要`
   - Starting from the next line, describe the processing contained in the entire Demo folder.
   - Use numbered items `1.`, `2.`, `3.` etc.
   - Keep the descriptions as concise as possible.
2. `前提/制約条件`
3. `前提条件：`
   - List prerequisites with Markdown list items.
   - If none exist, write `None`.
4. `制約条件：`
   - List constraints with Markdown list items.
   - If none exist, write `None`.
5. `処理概要図`
   - Add the processing overview diagram/content here.
6. `依存関係`
7. `使用公開API`
   - If no public API exists, write `None`.
   - Otherwise use a table with exactly these columns: `API名`, `種類`, `用途`.
8. `詳細設計`
   - Describe the Demo in Chinese as a textual representation of the code and its detailed processing.
9. `補足情報`
10. Message / CDS information
   - For a program that outputs messages, use the fixed heading `消息内容`, followed by a table with exactly these columns: `No`, `消息类`, `消息内容`, `参数`.
   - If the program has no messages, for example a CDS Demo, replace `消息内容` with the appropriate fixed information heading such as `CDS XXX 情報`, and use a table with exactly these columns: `fields`, `key`, `Annotations`, `Description`.
11. The final line must be `EOF`.

Do not add, remove, reorder, or rename the fixed sections unless the template itself is changed.

### 3. Self-Check

After creating or updating the README, AI must perform a manual self-check before considering the work complete.

The self-check must confirm at minimum:

- The README type matches the path depth.
- The correct template was used.
- The first line follows the template rule.
- Required blank-line placement is correct.
- Required headings are present.
- Heading order follows the template.
- The content is placed in the correct sections.
- List items and tables follow the required format.
- The final line is `EOF` for Demo README files.
- No template-required section was accidentally removed.
- Markdown formatting follows the template.
- Repository-specific content is accurate and consistent with the files represented by the README.

### 4. Automated Check

After the self-check, the README must be submitted to the repository's automated README validation process.

The planned validation mechanism is:

- Python script: `sap/abap/documents/script/check_readme.py`
- GitHub Actions: execute the Python validation against the relevant README files.

The Python validation will check the specified headings, structure, and content requirements. The automated check does not replace the AI self-check; both are required.

If the automated check fails, AI must inspect the failure, correct the README, perform the self-check again, and submit it for validation again.

## Standard Workflow

```text
Determine README type
        ↓
Check corresponding template
        ↓
Template exists?
   ├─ No → Stop and inform user
   └─ Yes
        ↓
Create / update README
        ↓
AI self-check
        ↓
Python + GitHub Actions validation
        ↓
Validation passed?
   ├─ No → Correct → Self-check → Validate again
   └─ Yes → Complete
```

## Important Constraints

1. Do not invent a README structure when the required template is missing.
2. Do not treat a list README and a demo README as interchangeable.
3. Do not skip the self-check because automated validation exists.
4. Do not consider the README complete until the automated validation has passed.
5. When updating an existing README, apply the same procedure as when creating a new README.
6. README content must describe the actual repository files and processing; do not add unsupported implementation details.
