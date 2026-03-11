# Terraform `.gitignore` Requirements

> These instructions apply to every Terraform module repository. A `.gitignore` file **must** exist at the repository root and at the root of every `examples/<scenario>/` folder. Missing or incomplete `.gitignore` files must be created or updated before any other work is committed.

---

## 1. Why a `.gitignore` is mandatory

Terraform writes several files to disk during normal operations that **must never** be committed:

| Path / pattern | Risk if committed |
|---|---|
| `.terraform/` | Vendor lock-in; binary provider plugins bloat the repo; path-dependent |
| `*.tfstate`, `*.tfstate.*` | May contain plaintext secrets, resource IDs, connection strings |
| `crash.log`, `crash.*.log` | May contain stack traces with sensitive variable values |
| `*.tfvars` (ad-hoc overrides) | Often contain environment-specific secrets or credentials |
| `override.tf`, `*_override.tf` | Local developer overrides; not intended for shared use |
| `.terraformrc`, `terraform.rc` | Contains credentials (e.g. Terraform Cloud tokens) |
| `*.tfbackend` | May contain storage credentials for remote backends |

---

## 2. Repository root `.gitignore`

Place the following file verbatim at the repository root. Do **not** modify the patterns without a documented rationale in a comment inside the file.

```gitignore
# ============================================================
# Terraform — local state (".terraform" provider cache)
# ============================================================
.terraform/
.terraform.lock.hcl

# ============================================================
# Terraform — state files
# ============================================================
*.tfstate
*.tfstate.*

# ============================================================
# Terraform — crash & diagnostic logs
# ============================================================
crash.log
crash.*.log

# ============================================================
# Terraform — variable files
# Only default.auto.tfvars (used by examples) is committed.
# All other .tfvars files are excluded to prevent accidental
# exposure of secrets or environment-specific settings.
# ============================================================
*.tfvars
*.tfvars.json

# ============================================================
# Terraform — local override files
# Override files are developer-local only and must never be
# shared as they silently change module behaviour.
# ============================================================
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# ============================================================
# Terraform — CLI and backend configuration
# These files can contain tokens and backend credentials.
# ============================================================
.terraformrc
terraform.rc
*.tfbackend

# ============================================================
# Examples — lock files ARE committed for examples because
# examples are root modules used for functional testing
# (see §3 below for the exception rule).
# ============================================================
!examples/**/.terraform.lock.hcl
```

> **Key distinction:** `.terraform.lock.hcl` is excluded at the **module root** (library modules do not pin provider versions for their consumers) but **re-included** for `examples/` sub-directories, which are standalone root modules used for functional testing.

---

## 3. `examples/<scenario>/` considerations

Every example subfolder is a **fully self-contained root module** (see `terraform_styleguide_example.instructions.md §2`). Because root modules should commit their lock files to guarantee reproducible `terraform init` runs in CI, the root `.gitignore` contains the negation pattern `!examples/**/.terraform.lock.hcl`.

No additional `.gitignore` is required inside each `examples/<scenario>/` folder; the root `.gitignore` covers the entire repository tree.

---

## 4. What must NOT be added to `.gitignore`

| Pattern | Reason |
|---|---|
| `default.auto.tfvars` | This file is intentionally committed — it auto-loads all variable values for examples (§5 of the example style guide). Never ignore it. |
| `versions.tf` | Required in every module and example. |
| `README.md` | Required at the module root (§2.3 of the module style guide). |
| `*.tf` (wildcard) | Would silently hide all Terraform source files. |
| `.terraform.lock.hcl` inside `examples/` | Covered by the negation rule `!examples/**/.terraform.lock.hcl`. |

```gitignore
# ✅ correct — only the module-root lock file is ignored
.terraform.lock.hcl
!examples/**/.terraform.lock.hcl

# ❌ wrong — would ignore the lock file even inside examples
.terraform.lock.hcl

# ❌ wrong — would accidentally ignore committed tfvars
*.tfvars
# (missing the !default.auto.tfvars exception — see §2 for the full block)
```

---

## 5. Checklist before committing

Before every commit, verify:

- [ ] `.gitignore` exists at the repository root.
- [ ] `.terraform/` directories are not staged (`git status` shows no `.terraform/` entries).
- [ ] No `*.tfstate` or `*.tfstate.*` files are staged.
- [ ] No `crash.log` or `crash.*.log` files are staged.
- [ ] `default.auto.tfvars` files in `examples/` are staged (not accidentally ignored).
- [ ] `examples/**/.terraform.lock.hcl` files are staged when the lock file has changed.
- [ ] No `*.tfvars` files outside `examples/` containing credentials are staged.

---

## 6. Enforcement via HCP Terraform policy

When this module's workspaces are managed in HCP Terraform / Terraform Enterprise, a **Sentinel** or **OPA policy set** should be attached to enforce that no state file or credential file is accessible outside the workspace:

> Use `mcp_terraform_pri_attach_policy_set_to_workspaces` to attach an approved policy set to the module workspaces after workspace creation. This ensures repository-level `.gitignore` rules are complemented by platform-level access controls.

```bash
# Example: attach a policy set using the MCP tool
# mcp_terraform_pri_attach_policy_set_to_workspaces
#   policy_set_id  = "<approved-policy-set-id>"
#   workspace_ids  = ["<workspace-id>"]
```
