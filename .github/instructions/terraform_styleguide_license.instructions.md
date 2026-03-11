# Terraform `LICENSE` Requirements

> These instructions apply to every Terraform module repository owned by Xebia Germany. A `LICENSE` file **must** exist at the repository root. Missing or incorrect `LICENSE` files must be created or corrected before any other work is committed.

---

## 1. Why a `LICENSE` file is mandatory

A `LICENSE` file:

- Legally establishes Xebia Germany GmbH as the copyright owner of the module.
- Defines the terms under which consumers may use, copy, modify, and distribute the module.
- Is required by the [Terraform Registry](https://registry.terraform.io/) for public module publication.
- Prevents accidental "all rights reserved" status, which would block external use entirely.

---

## 2. Approved license: Apache 2.0

All Terraform modules published by Xebia Germany use the **Apache License, Version 2.0**.

**Rationale:**

| Property | Apache 2.0 |
|---|---|
| Permissive | ✅ Consumers may use commercially without restriction |
| Patent grant | ✅ Explicit patent license from contributors |
| Attribution required | ✅ Copyright notice must be preserved |
| Compatible with Terraform Registry | ✅ Required for public module listing |
| Used by HashiCorp | ✅ Consistent with the Terraform ecosystem |

Do **not** use MIT, GPL, or proprietary licenses for Terraform modules in this organisation.

---

## 3. Required `LICENSE` file content

The `LICENSE` file at the repository root **must** begin with the copyright notice on the very first line, followed by the full verbatim Apache 2.0 license text:

```
Copyright (c) <YEAR> Xebia Germany GmbH

                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/
   ...(full Apache 2.0 text)...
```

Where `<YEAR>` is the year the repository was first created (not the current year on each edit).

The copyright line **must** appear at the top of the file, before the `Apache License` header — this is the standard format used by Terraform module repositories (terraform-aws-modules, Azure official modules, etc.) and is required for the Terraform Registry to correctly attribute ownership.

The file must be named exactly `LICENSE` (no extension, capital letters). Do **not** use `LICENSE.txt`, `LICENSE.md`, or `license`.

---

## 4. File placement

```
.                   ← LICENSE lives here
├── LICENSE         ✅ Single file at repo root, no extension
├── main.tf
├── versions.tf
└── examples/
    └── defaults/
        └── ...     ← NOT a separate LICENSE; root covers all
```

- No `LICENSE` file should be placed inside `examples/<scenario>/` subdirectories.
- The root `LICENSE` covers the entire repository tree.
- The `LICENSE` file **must** be committed to version control — it is legal documentation, not developer-local state.

---

## 5. What must NOT be done

| Action | Reason |
|---|---|
| Changing the copyright holder away from "Xebia Germany GmbH" | Legal requirement |
| Using a non-Apache-2.0 license | Organisation policy |
| Adding the `.terraform.lock.hcl` exception to the `LICENSE` | Not applicable |
| Omitting the `LICENSE` from a new module repository | Terraform Registry will reject the module |
| Naming the file `LICENSE.txt` or `license` | Registry and tooling expect exact casing `LICENSE` |
