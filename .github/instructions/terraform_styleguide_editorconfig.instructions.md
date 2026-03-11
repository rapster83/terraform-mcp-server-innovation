# Terraform `.editorconfig` Requirements

> These instructions apply to every Terraform module repository. An `.editorconfig` file **must** exist at the repository root. It encodes the canonical formatting rules for every file type in the repository and is enforced automatically by editors that support the [EditorConfig](https://editorconfig.org/) standard (VS Code, JetBrains IDEs, Vim, Neovim, etc.).

---

## 1. Why `.editorconfig` is mandatory

Terraform's formatter (`terraform fmt`) defines strict, non-negotiable whitespace rules for `.tf` and `.tfvars` files. Without a shared `.editorconfig`, editors silently apply their own defaults (tabs vs. spaces, CRLF vs. LF, trailing whitespace) and produce noisy diffs that obscure real changes.

| Risk if omitted | Impact |
|---|---|
| Mixed indentation (tabs + spaces) | `terraform fmt` rewrites entire files on every run, producing large diffs |
| CRLF line endings on Windows | `terraform validate` may fail on Linux/macOS CI; state drift in git |
| Trailing whitespace | Clutters `git diff`; trips up linters |
| No final newline | POSIX-non-conformant; breaks some diff tools |
| Inconsistent Markdown / JSON formatting | PR reviews harder to read |

---

## 2. Repository root `.editorconfig`

Place the following file verbatim at the repository root. Do **not** modify indentation sizes or line-ending settings for `.tf` files — they must match what `terraform fmt` produces.

```editorconfig
# EditorConfig — https://editorconfig.org
# Terraform modules: canonical whitespace rules aligned with `terraform fmt`.
# Do NOT change indent_size or end_of_line for [*.tf] — these must match
# what `terraform fmt` enforces.

root = true

# ── Defaults (all files) ────────────────────────────────────────────────────
[*]
charset                  = utf-8
end_of_line              = lf
indent_style             = space
indent_size              = 2
trim_trailing_whitespace = true
insert_final_newline     = true

# ── HCL / Terraform ─────────────────────────────────────────────────────────
# terraform fmt uses 2-space soft indentation and LF line endings.
[*.{tf,tfvars,hcl}]
indent_style = space
indent_size  = 2
end_of_line  = lf

# ── Markdown ─────────────────────────────────────────────────────────────────
# Trailing whitespace is meaningful in Markdown (two spaces = <br>).
# Turn off trim_trailing_whitespace to preserve intentional line breaks.
[*.{md,mdx}]
trim_trailing_whitespace = false

# ── JSON / YAML ──────────────────────────────────────────────────────────────
[*.{json,yaml,yml}]
indent_style = space
indent_size  = 2

# ── Shell scripts ────────────────────────────────────────────────────────────
[*.sh]
end_of_line = lf

# ── Windows batch / PowerShell ───────────────────────────────────────────────
[*.{bat,cmd,ps1}]
end_of_line = crlf
```

---

## 3. File placement and scope

- The `.editorconfig` file lives at the **repository root** (`/`). Because `root = true` is set, EditorConfig stops traversing parent directories at this file.
- No additional `.editorconfig` files should be placed inside `examples/<scenario>/` subdirectories. The root file's glob patterns cover the entire tree.
- The file must be **committed to version control** — it is project configuration, not developer-local state.

```
.                          ← root = true lives here
├── .editorconfig          ✅ committed, single file for entire repo
├── main.tf
├── versions.tf
└── examples/
    └── defaults/
        ├── main.tf        ← covered by root .editorconfig globs
        └── providers.tf   ← covered by root .editorconfig globs
```

---

## 4. Alignment with `terraform fmt`

`terraform fmt` (and the underlying HCL formatter) enforces:

| Rule | Value | `.editorconfig` setting |
|---|---|---|
| Indentation style | Spaces | `indent_style = space` |
| Indentation size | 2 spaces | `indent_size = 2` |
| Line endings | LF (`\n`) | `end_of_line = lf` |
| Trailing whitespace | Removed | `trim_trailing_whitespace = true` |
| Final newline | Required | `insert_final_newline = true` |

> **Do not** set `indent_style = tab` or `indent_size = 4` for `[*.tf]` blocks. Even if an editor inserts tabs, `terraform fmt` will immediately convert them to spaces, creating a permanent format-on-save loop and noisy commits.

```editorconfig
# ✅ correct — matches terraform fmt output
[*.{tf,tfvars,hcl}]
indent_style = space
indent_size  = 2
end_of_line  = lf

# ❌ wrong — terraform fmt will immediately rewrite every file
[*.{tf,tfvars,hcl}]
indent_style = tab
indent_size  = 4
```

---

## 5. What must NOT be excluded or overridden

| Setting | Do not change | Reason |
|---|---|---|
| `indent_size` for `[*.tf]` | Must remain `2` | `terraform fmt` hard-codes 2-space indentation |
| `end_of_line` for `[*.tf]` | Must remain `lf` | CI runs on Linux; CRLF causes `terraform validate` failures |
| `charset` | Must remain `utf-8` | Provider strings, resource names, and tag values may contain non-ASCII characters |
| `insert_final_newline` | Must remain `true` | POSIX compliance; git shows "no newline at end of file" warnings otherwise |

---

## 6. Checklist before committing

- [ ] `.editorconfig` exists at the repository root.
- [ ] `root = true` is the **first non-comment line** in the file.
- [ ] `[*.{tf,tfvars,hcl}]` section uses `indent_style = space`, `indent_size = 2`, `end_of_line = lf`.
- [ ] `[*.{md,mdx}]` section sets `trim_trailing_whitespace = false`.
- [ ] The file itself ends with a newline (i.e. follows its own rules).
- [ ] `terraform fmt -recursive .` produces **no changes** after the `.editorconfig` is applied.

---

## 7. Enforcement via HCP Terraform policy

Repository-level formatting conventions are enforced locally by EditorConfig-aware editors and CI `terraform fmt --check` steps. When the module's workspaces are managed in HCP Terraform / Terraform Enterprise, attach a policy set that validates formatting consistency across all workspaces:

> Use `mcp_terraform_pri_attach_policy_set_to_workspaces` to attach an approved Sentinel or OPA policy set to the module's workspaces. Platform-level policies complement (but do not replace) the `.editorconfig` file.

```bash
# Example: attach a policy set using the MCP tool
# mcp_terraform_pri_attach_policy_set_to_workspaces
#   policy_set_id = "<approved-policy-set-id>"
#   workspace_ids = ["<workspace-id>"]
```
