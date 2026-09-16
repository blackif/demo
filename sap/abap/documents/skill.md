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

The first line must be the current folder name followed by `List Preview`.

Example:

```text
ABAP List Preview
```

Then leave exactly one blank line. Starting from the third line, list the child folder links and their descriptions.

Each list item must follow this format:

```text
- [Folder Name](./folder/) — Description
```

There must be no additional blank lines between list items.

#### Demo README Rules

The title and section structure must follow `sap/abap/documents/template/demo.md` exactly.

The current template uses the first line format:

```text
# [Previous folder name] [Current Folder Name]
```

Then the following headings and subheadings must exist and remain in the same order:

```text
## 処理概要
## 前提/制約条件
### 前提条件：
### 制約条件：
## 処理概要図
## 依存関係
### 使用公開API
## 詳細設計
## 補足情報
### 消息内容
EOF
```

Rules for the sections:

- `処理概要`: describe the processing contained in the entire Demo folder using concise numbered items.
- `前提条件：`: list prerequisites. If none exist, use `None`.
- `制約条件：`: list constraints. If none exist, use `None`.
- `処理概要図`: record the processing overview diagram/content.
- `使用公開API`: record the CDS Views, Views, Database Tables, and other relevant publicly available SAP objects or APIs actually used by the Demo. If none exist, use `None`. Use the template table columns `API名`, `種類`, `用途`.
- `詳細設計`: describe the Demo's detailed implementation and processing based on the actual code. There is no requirement to use Chinese.
- `補足情報`: record message information only. If the Demo has no messages, use `None`.
- `消息内容`: when messages exist, use the message table defined by the template.
- The final line must be `EOF`.

Do not add, remove, reorder, or rename template-required headings unless the template itself is changed.

### 3. Self-Check

After creating or updating the README, AI must perform a manual self-check before considering the work complete.

The self-check must confirm at minimum:

- The README type matches the path depth.
- The correct template was used.
- The first line follows the template rule.
- Required blank-line placement is correct.
- Required headings and subheadings are present.
- Heading order follows the template.
- The content is placed in the correct sections.
- List items and tables follow the required format.
- `使用公開API` records the CDS Views, Views, Database Tables, and other relevant objects actually used by the Demo, or `None` when there are none.
- `補足情報` contains only message information, or `None` when there are no messages.
- The final line is `EOF` for Demo README files.
- No template-required section was accidentally removed.
- Markdown formatting follows the template.
- Repository-specific content is accurate and consistent with the files represented by the README.

### 4. Automated Check

When a repository change includes a `README.md` file, GitHub Actions must execute the README validation process.

The validation script is:

`sap/abap/documents/script/check_readme.py`

The script behavior is:

1. Check whether the changed file is `README.md`. If not, stop processing that file successfully.
2. Determine the README type from the repository-relative path depth:
   - Third or fourth level → List README.
   - Fifth level → Demo README.
   - Other depths → validation failure.
3. For a List README, validate against `sap/abap/documents/template/list.md`:
   - Validate the title format `[Current Folder Name] List Preview`.
   - Validate every content line against `- [Folder Name](./folder/) — Description`.
   - Do not allow unexpected blank lines in the list content.
4. For a Demo README, validate against `sap/abap/documents/template/demo.md`:
   - Validate the title format defined by the template.
   - Validate that all required headings and subheadings exist.
   - Validate that the headings and subheadings appear in the template order.
   - Validate that the README ends with `EOF`.

The automated check does not replace the AI self-check; both are required.

If the automated check fails, AI must inspect the failure, correct the README, perform the self-check again, and submit it for validation again.

## Standard Workflow

```text
README changed?
   ├─ No → Stop
   └─ Yes
        ↓
Check README type
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
Python check_readme.py
        ↓
GitHub Actions validation
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
7. `詳細設計` has no Chinese-language requirement.
8. `補足情報` is limited to message information; if there are no messages, use `None`.
9. `使用公開API` must include the CDS Views, Views, Database Tables, and other relevant public objects or APIs actually used by the Demo.
10. GitHub Actions should run the README checker only when a changed file is `README.md`.
