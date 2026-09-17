# SAP ABAP README and Issue Creation Skill

## Purpose

This skill defines the standard procedure for creating or updating README files and GitHub Issues under `sap/abap/` so that documentation and user-confirmation tasks remain consistent across the repository.

## README Rules

AI must execute the following steps in order whenever it creates or modifies a README file.

### 1. Determine README Type

Determine whether the target README is a **List README** or a **Demo README** from its repository-relative path depth.

- **List README**: third or fourth path level, e.g. `sap/abap/README.md`, `sap/abap/rap/README.md`, `sap/abap/Classical/README.md`.
- **Demo README**: fifth path level, e.g. `sap/abap/Classical/demo1/README.md`.

The path level must be determined from the repository-relative path, not the local filesystem path.

### 2. Check and Apply the Correct Template

Before editing, check the corresponding template under `sap/abap/documents/template/`:

- List README → `sap/abap/documents/template/list.md`
- Demo README → `sap/abap/documents/template/demo.md`

If the required template does not exist, stop and inform the user. Do not assume a format.

#### List README Rules

The first line must be `[Current Folder Name] List Preview`. Then exactly one blank line, followed by child-folder links in the form:

```text
- [Folder Name](./folder/) — Description
```

No additional blank lines are allowed between list items.

#### Demo README Rules

The title and section structure must follow `sap/abap/documents/template/demo.md` exactly:

```text
# [Previous folder name] [Current Folder Name]
## 処理概要
## 前提/制約条件
### 前提条件：
### 制約条件：
## 処理概要図
## 依存関係
### 使用公開API
## 詳細設計
## 補足情報
### 目录構造
EOF
```

Unless otherwise noted, all Demo README content must be Japanese. `詳細設計` is exempt from the language rule.

- `処理概要`: concise numbered description of the actual Demo processing.
- `前提条件：`: prerequisites, or `None` if none exist.
- `制約条件：`: constraints, or `None` if none exist.
- `処理概要図`: processing overview diagram/content.
- `使用公開API`: inventory of all relevant objects actually used, including transitive dependencies. Inspect every implementation file in the Demo. For every CDS/View Entity/Projection View, recursively inspect `select from`, `join`, and `association` targets until terminal SAP standard objects, database tables/views, or other terminal objects are reached. Include SAP standard/public APIs, custom CDS/Views, tables/views, function modules, interfaces, classes, BAdIs, User-Exits, VOFM routines, and other referenced objects. Do not omit indirect CDS dependencies. Consolidate duplicates. Use columns `API名`, `種類`, `用途`.
- `詳細設計`: describe the actual implementation and processing.
- `補足情報` / `目录構造`: record the actual Demo directory/file structure only.
- The final line must be `EOF`.

### 3. Self-Check

Before considering README work complete, AI must confirm at minimum:

- README type and template are correct.
- Title, blank lines, headings, heading order, tables, and Markdown format are correct.
- All required headings are present and no extra `##`/`###` headings were added.
- Content accurately describes actual repository files.
- `使用公開API` covers the complete recursive/transitive dependency chain without invented objects.
- Directory structure is actual.
- Demo README ends with `EOF`.
- Japanese language rule is satisfied except `詳細設計`.

### 4. Automated Check

When a repository change includes a `README.md`, GitHub Actions must execute `sap/abap/documents/script/check_readme.py`.

The script determines README type from repository-relative path depth and validates List README files against `template/list.md` and Demo README files against `template/demo.md`, including title/format, required headings/order, and Demo `EOF` termination.

The automated check does not replace the AI self-check. If validation fails, correct the README, self-check again, and validate again.

## Issue Rules

GitHub Issues must follow `sap/abap/documents/template/issue.md` exactly:

```text
## 任务
{{Task}}

## 要求
- {{Requirement}}

## 验收条件
- [ ] {{Checklist item}}
```

Every Issue must contain exactly these three sections. One Issue represents one task. Do not add custom status, Output, parent, or child fields.

### Issue Self-Check

Before creating an Issue, confirm:

- Exactly one task is described.
- `任务` contains one clear task.
- `要求` has at least one concrete requirement.
- `验收条件` has at least one concrete checklist item.
- Expected output is represented by an acceptance checklist item.
- No unapproved sections or status fields exist.

## Review Label Rules — Strict Gate

**The `review` label means that the task has been completed by AI and is now waiting for Human Review. Therefore, `review` MUST NOT be added to a newly created or unfinished Issue.**

The following rule is absolute:

> **Only when ALL `验收条件` checklist items in the Issue are `[x]` may the `review` label be added. If even one checklist item remains `[ ]`, the Issue MUST NOT have the `review` label.**

This rule applies to all Issues generated or managed by the SAP ABAP README workflow, including Demo README Issues and List README synchronization Issues.

When an Issue is created:

1. Its `验收条件` checklist items must initially be `[ ]`.
2. Do **not** add `review`.
3. If an old or incorrectly configured Issue already has `review` while any acceptance item is `[ ]`, remove `review` immediately.

When an Issue is updated:

1. Re-read the current Issue body.
2. Determine the state of every `验收条件` checkbox.
3. If any checkbox is `[ ]`, `review` must be absent.
4. Only if every checkbox is `[x]`, `review` may be added.
5. Changing an Issue to `review` must never itself mark a checkbox complete.

`review` is therefore a **post-completion label**, not a task-creation label and not an execution permission.

## Demo Folder Issue Flow

When a new fourth-level Demo folder is created under `sap/abap/`, GitHub Actions creates one README task Issue automatically.

The generated Issue must:

1. Use `sap/abap/documents/template/issue.md`.
2. Contain exactly `任务`, `要求`, and `验收条件`.
3. Have exactly one acceptance checklist item for successful creation of the Demo `README.md` with a repository hyperlink.
4. Require analysis of the entire Demo directory.
5. Require reading and following `sap/abap/documents/skill.md` and `sap/abap/documents/template/demo.md`.
6. Require the README to describe the actual implementation and pass `sap/abap/documents/script/check_readme.py`.
7. **Must not receive the `review` label when created.**

GitHub Actions must not create the README automatically. It only creates the task Issue. Actual README creation is controlled by the `Todo` gate below.

## List README Synchronization Issue Flow

When the README checker detects that a List README is out of sync with its actual direct child folders, GitHub Actions creates or updates one synchronization Issue.

The synchronization Issue:

1. Uses the standard three Issue sections.
2. Contains unchecked acceptance criteria while the synchronization is incomplete.
3. **Must not receive the `review` label while any acceptance criterion is unchecked.**
4. May receive `review` only after every acceptance criterion is marked `[x]`.

## Todo Label Gate for README Creation

For a Demo README Issue, **AI must not create or modify the Demo `README.md` unless the specified Issue currently has the `Todo` label**.

The presence or absence of `review` never grants permission to create the README. `Todo` is the explicit execution gate.

Before starting README creation:

1. Identify the exact Issue assigned to the Demo.
2. Read the current Issue labels.
3. Confirm that `Todo` is present.
4. If `Todo` is absent, stop without creating or modifying the Demo README.
5. If `Todo` is present, analyze the Demo, read the Skill/template, create or modify the README, self-check, and run automated validation.

After successful README creation and validation:

1. Mark the acceptance checkbox `[x]`.
2. Remove `Todo`.
3. Only after confirming that **all** acceptance checkboxes are `[x]`, add `review`.
4. Do not remove unrelated labels unless explicitly required.

If validation fails:

- Do not mark any acceptance checkbox complete.
- Do not remove `Todo`.
- Ensure `review` is absent.
- Correct the README and validate again.

### Label Transition

```text
New Task Issue
      ↓
验收条件 = [ ]
      ↓
NO review
      ↓
Human adds Todo when ready for AI execution
      ↓
AI executes task
      ↓
Self-check + automated validation
      ↓
All 验收条件 = [x]
      ↓
Todo removed
      ↓
review added
      ↓
Human Review
```

## Issue Completion

An Issue is complete when all `验收条件` have been satisfied and the Human closes the GitHub Issue. The AI must not add a custom status field.

## Standard Workflow

```text
Task Issue created
   ↓
All 验收条件 unchecked
   ↓
No review label
   ↓
Todo gate (when AI execution is required)
   ↓
AI executes task
   ↓
Self-check
   ↓
Automated validation
   ↓
Validation passed?
   ├─ No → Correct → Self-check → Validate again
   └─ Yes
        ↓
Mark ALL 验收条件 [x]
        ↓
Remove Todo
        ↓
Confirm ALL 验收条件 [x]
        ↓
Add review
        ↓
Human Review
```

## Important Constraints

1. Never invent a README structure when the required template is missing.
2. Do not treat List README and Demo README as interchangeable.
3. Do not skip AI self-check.
4. Do not consider README complete until automated validation passes.
5. README content must describe actual repository files and processing.
6. Demo README content must be Japanese except `詳細設計`.
7. `使用公開API` must include complete recursive/transitive dependencies actually used by the Demo.
8. Issue content must follow the current Issue template exactly.
9. A newly created fourth-level Demo folder must receive a README task Issue automatically; the Action must not create the README itself.
10. A Demo README may only be created or modified when the corresponding Issue has `Todo`.
11. **`review` may only exist when every `验收条件` checkbox in that Issue is `[x]`.**
12. **If any acceptance checkbox is `[ ]`, `review` must be removed and must not be re-added until all acceptance criteria are `[x]`.**
13. After successful AI execution, all acceptance criteria must be checked before `review` is added.
