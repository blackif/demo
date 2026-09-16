# SAP ABAP README Creation Skill

## Purpose

This skill defines the standard procedure for creating or updating README files under `sap/abap/` so that documentation format remains consistent across the repository.

## Execution Rules

AI must execute the following steps in order whenever it creates or modifies a README file.

### 1. Determine README Type

First determine whether the target README is a **list README** or a **demo README** from its path depth.

- **List README**: the README is located at the third or fourth path level.
  - Example: `sap/abap/README.md`
  - Example: `sap/abap/rap/README.md`
  - Example: `sap/abap/Classical/README.md`
- **Demo README**: the README is located at the fifth path level.
  - Example: `sap/abap/Classical/demo1/README.md`

The path level must be determined from the repository-relative path, not from the local filesystem path.

### 2. Edit README Using the Correct Template

Before editing the README, AI must check the corresponding template under:

`sap/abap/documents/template/`

- List README → `sap/abap/documents/template/list.md`
- Demo README → `sap/abap/documents/template/demo.md`

The README must strictly follow the corresponding template's structure and formatting.

If the required template file does not exist, **stop the remaining steps** and inform the user that the corresponding template is missing. Do not create or modify the target README based on an assumed format.

### 3. Self-Check

After creating or updating the README, AI must perform a manual self-check before committing the change.

The self-check must confirm at minimum:

- The README type matches the path depth.
- The correct template was used.
- The required headings are present.
- The heading order follows the template.
- The content is placed in the correct sections.
- No template-required section was accidentally removed.
- Markdown formatting follows the template.
- Repository-specific content is accurate and consistent with the files represented by the README.

### 4. Automated Check

After the self-check, the README must be submitted to the repository's automated README validation process.

The planned validation mechanism is:

- Python script: `sap/abap/documents/script/check_readme.py`
- GitHub Actions: execute the Python validation against the relevant README files.

The Python validation will check specified headings and content requirements. The automated check does not replace the AI self-check; both are required.

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
