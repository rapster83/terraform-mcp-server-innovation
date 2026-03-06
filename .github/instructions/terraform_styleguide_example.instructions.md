---
applyTo: "examples/**/*.tf"
---

# Terraform Style Guide for Module Examples

> These instructions apply to all files inside any `examples/` subdirectory of a Terraform module.
> Reference implementation: [`rapster83/terraform-azurerm-kubernetes`](https://github.com/rapster83/terraform-azurerm-kubernetes/tree/main/examples)

---

## 1. Purpose of examples

Every module **must** ship a working example. Examples serve two purposes:

1. **Functional testing** — each example is a real Terraform root module that can be `init`/`apply`ed against a live environment.
2. **Usage documentation** — readers learn how to call the module by reading the example, not the prose README.

---

## 2. Example folder layout

```
examples/
├── defaults/          # minimal happy-path — every resource the module can manage
└── customer_<name>/   # real-world scenario demonstrating a specific deployment pattern
```

- Each subfolder is a **fully self-contained Terraform root module** (its own `providers.tf`, `main.tf`, `*.tfvars`, etc.).
- Folder names use `snake_case`.
- Every module ships at minimum one `defaults` example. Additional `customer_<name>` examples are added for non-trivial real-world patterns.

### File structure per example folder

```
examples/<scenario>/
├── providers.tf                          # Terraform + required_providers block
├── data.tf                               # Data sources only (optional)
├── main.tf                               # Supporting resources + single module call
├── locals.tf                             # Local values (optional)
├── default.auto.tfvars                   # All variable values (auto-loaded)
├── variables_globals.tf                  # Subscription, location, tags
├── variables_resource_group.tf           # Resource group toggle + name
├── variables_<resource_type>.tf          # One file per module-exposed resource type
└── outputs_<resource_type>.tf            # One file per module-exposed resource type
```

- **No** `terraform.tfvars` — use only `default.auto.tfvars` so values are applied automatically.
- **No** `backend.tf` — examples use the local (default) backend.

---

## 3. `providers.tf`

Pin Terraform version with a pessimistic constraint (`~>`). Pin each provider to the same minor family used in the module's `versions.tf`.

```hcl
terraform {
  required_version = "~> 1.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.default_subscription_id
  features {}
}
```

- Only declare providers actually used in the example.
- `subscription_id` **must** be sourced from a variable — never hard-coded.

---

## 4. `data.tf`

Keep data sources in a dedicated `data.tf`. Common data sources:

```hcl
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}   # only when azuread is required

data "http" "myip" {
  url = "https://ipv4.myip.wtf/text"         # used to restrict Key Vault / API server firewall rules
}
```

- `data "http" "myip"` replaces any hard-coded IP address for firewall allow-lists. Reference it as `trimspace(data.http.myip.response_body)`.

---

## 5. `main.tf`

`main.tf` has two clearly separated sections:

### Section 1 — Supporting / prerequisite resources

Everything the module depends on but does **not** manage itself: VNets, subnets, Key Vaults, Log Analytics Workspaces, Application Gateways, etc.

Rules:
- Use **specific, human-readable names** for each resource (not `this`) so the example reads like real infrastructure code.
- Follow naming convention: `<type>-<name>-<region>-<env>-<num>` (e.g., `aks-starks-weu-dev-01`, `kv-k8s-weu-dev-01`).
- Add `depends_on` at the module level when role assignments must complete before the module runs.

### Section 2 — Module call

A **single module block** named `"defaults"`, placed at the very end of `main.tf`.

```hcl
module "defaults" {
  depends_on = [azurerm_role_assignment.administrator]  # only if needed
  source     = "../.."

  # globals
  module_location = var.module_location
  module_tags     = var.module_tags

  # azurerm_resource_group
  resource_group_create = var.resource_group_create
  resource_group_name   = var.resource_group_name

  # azurerm_key_vault_key
  key_vault_keys = var.key_vault_keys
  key_vault_key_key_vault_ids = {
    (azurerm_key_vault.this.name) = azurerm_key_vault.this.id
  }

  # azurerm_kubernetes_cluster_node_pool
  kubernetes_cluster_node_pools = var.kubernetes_cluster_node_pools

  # azurerm_monitor_diagnostic_setting
  monitor_diagnostic_settings = var.monitor_diagnostic_settings
  monitor_diagnostic_setting_resource_ids = {
    (azurerm_log_analytics_workspace.this.name) = azurerm_log_analytics_workspace.this.id
  }
}
```

Rules:
- Module local name is always `"defaults"` — do not change it.
- `source` is always the relative path `"../.."` (two levels up from the example subfolder to the module root).
- Group arguments by resource type. Prefix each group with a comment: `# azurerm_<resource_type>`.
- **ID lookup maps** (e.g., `key_vault_key_key_vault_ids`) are always constructed inline inside the module block using the supporting resource names as keys: `{ (azurerm_key_vault.this.name) = azurerm_key_vault.this.id }`.
- Pass all other variables through `var.<variable_name>` — never inline literal values for configurable attributes.

---

## 6. `variables_globals.tf`

Every example must have this file with exactly these three variables:

```hcl
variable "default_subscription_id" {
  type        = string
  description = "The Azure Subscription ID where the resources should be created. Changing this forces a new resource to be created."
}

variable "module_location" {
  description = "The Azure region where the resources should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "westeurope"
}

variable "module_tags" {
  description = "A mapping of tags which should be assigned to all resources of the module."
  type        = map(string)
  default     = null
}
```

- `default_subscription_id` is **required** (no default) — callers must always supply it.
- `module_location` defaults to `"westeurope"` unless the module targets a different primary region.

---

## 7. `variables_<resource_type>.tf`

One file per resource type the module exposes, mirroring the module's own variable file.

Rules:
- **Filename** matches the module's internal variable file: `variables_<resource_type>.tf`.
- **Variable ordering** inside the file follows the same order as the module's variable declarations (which in turn follow the Terraform provider documentation argument order).
- **Type definitions** are copied verbatim from the module — do not simplify or shorten `optional()` wrappers.
- Default is always `null` for map-based configuration variables.
- Variable attribute order: `type → description → default` (same as the module style guide § 3.3).

```hcl
# variables_kubernetes_cluster_node_pool.tf
variable "kubernetes_cluster_node_pools" {
  type = map(object({
    kubernetes_cluster_id        = optional(string, null)
    kubernetes_cluster_name      = optional(string, null)
    name                         = string
    vm_size                      = string
    auto_scaling_enabled         = optional(bool, true)
    host_encryption_enabled      = optional(bool, true)
    min_count                    = optional(number, null)
    max_count                    = optional(number, null)
    node_count                   = optional(number, null)
    os_disk_size_gb              = optional(number, null)
    vnet_subnet_name             = optional(string, null)
    availability_zones           = optional(list(string), null)
    tags                         = optional(map(string), null)
    node_network_profiles = optional(map(object({
      application_security_group_names = optional(list(string), null)
      allowed_host_ports = optional(map(object({
        protocol   = optional(string, null)
        port_start = optional(number, null)
        port_end   = optional(number, null)
      })), null)
    })), null)
  }))
  description = "Map of Node Pool configurations for the Kubernetes Cluster."
  default     = null
}
```

---

## 8. `outputs_<resource_type>.tf`

One file per resource type the module exposes. Each output directly proxies the module output.

```hcl
# outputs_resource_group.tf
output "resource_group_id" {
  description = "The ID of the resource group (RG)."
  value       = module.defaults.resource_group_id
}

output "resource_group_name" {
  description = "The name of the resource group (RG)."
  value       = module.defaults.resource_group_name
}
```

```hcl
# outputs_kubernetes_flux_configuration.tf
output "kubernetes_flux_configuration_ids" {
  description = "The IDs of the Kubernetes Flux Configurations."
  value       = module.defaults.kubernetes_flux_configuration_ids
}
```

Rules:
- Output attribute order: `description → value` (omit `sensitive` unless the module output itself is sensitive).
- `value` always references `module.defaults.<output_name>` — never re-compute in the example.
- Include **every** output the module exposes — do not filter or selectively expose outputs.

---

## 9. `default.auto.tfvars`

All variable values live here. Terraform auto-loads this file, so no `-var-file` flag is needed.

### Structure

```hcl
# globals
default_subscription_id = "00000000-0000-0000-0000-000000000000"
module_tags = {
  environment  = "dev"
  managed_by   = "terraform"
}

# azurerm_resource_group
resource_group_name = "rg-k8s-weu-dev-01"

# azurerm_key_vault_key
key_vault_keys = {
  key-des-weu-dev-01 = {
    key_vault_name  = "kv-k8s-weu-dev-01"
    expiration_date = "2026-01-01T12:00:00Z"
    rotation_policies = {
      ab32cc30-9aeb-4f1c-8b73-d19c2cbeafce = {
        expire_after         = "P180D"
        notify_before_expiry = "P15D"
        automatics = {
          f7e9434a-d066-4a38-aa86-f6b63c1ead32 = {
            time_before_expiry = "P10D"
          }
        }
      }
    }
  }
}
```

### Map key conventions

| Resource pattern | Key convention | Example |
|-----------------|---------------|---------|
| Named resources (deterministic) | Resource name string | `key-des-weu-dev-01` |
| Anonymous nested objects (non-deterministic) | UUID v4 | `ab32cc30-9aeb-4f1c-8b73-d19c2cbeafce` |
| Role assignments | UUID v4 (principal object ID or generated) | `de514dd4-0fd8-4402-903a-f687c420bca1` |

- UUIDs prevent `for_each` key conflicts when resource names are not yet known.
- Use `optional()` defaults — only specify attributes that differ from the module default.
- **Comment out** optional sections that are not active but worth documenting. Provide a brief explanation above commented blocks:

```hcl
# # azurerm_disk_encryption_set (optional — only required when CMK encryption is enabled)
# disk_encryption_set_name               = "des-k8s-weu-dev-01"
# disk_encryption_set_key_vault_key_name = "key-des-weu-dev-01"
```

### Resource naming convention

Follow `<type>-<name>-<region>-<env>-<num>`:

| Segment | Example |
|---------|---------|
| `<type>` | `aks`, `kv`, `rg`, `vnet`, `snet`, `appgw`, `log`, `uai` |
| `<name>` | `k8s`, `starks` (customer/workload) |
| `<region>` | `weu` (West Europe), `neu` (North Europe) |
| `<env>` | `dev`, `uat`, `prod` |
| `<num>` | `01`, `02` |

---

## 10. Example scenarios

### `defaults` — Minimal happy-path example

- Deploys every resource type the module can manage.
- Sets `resource_group_create = false` (resource group is created as a supporting resource in `main.tf`).
- Uses only module defaults where possible; explicitly sets optional parameters to demonstrate their effect.
- Variable values in `default.auto.tfvars` use the `k8s-weu-dev` naming family.

### `customer_<name>` — Real-world scenario example

- Models a concrete, named customer deployment.
- May omit resource types not relevant to that customer's use case.
- Sets `resource_group_create = true` — the module manages the resource group.
- Shows real-world patterns: multiple node pools, flux configurations, role assignments, AGIC integration, etc.
- Variable values use a customer-specific naming family (e.g., `starks-weu-dev`).
- Sensitive or company-specific values (email addresses, principal names) are anonymised in the repository but the structure is preserved.
- Contains richer inline comments explaining **why** each configuration choice was made.

---

## 11. Role assignments in examples

Role assignments in `default.auto.tfvars` use UUID v4 keys and the following structure:

```hcl
role_assignments = {

  # <Role> - <Scope description>
  de514dd4-0fd8-4402-903a-f687c420bca1 = {
    scope_name           = "privatelink.westeurope.azmk8s.io"
    role_definition_name = "Private DNS Zone Contributor"
    description          = "Lets you manage private DNS zone resources, but not the virtual networks they are linked to."
  }

  # <Role> - <Scope description>
  cb291609-5fa3-4edb-b30d-943778c429ee = {
    scope_name           = "ApiServerSubnet"
    role_definition_name = "Network Contributor"
    description          = "Lets you manage networks, but not access to them."
  }
}
```

- Group assignments by role/purpose, separated by a comment line.
- Always provide `description` to explain the business reason for the permission.
- Prefer `scope_name` over `scope_id` so the example is human-readable.

---

## 12. Checklist before committing an example

- [ ] `providers.tf` pins both `required_version` and all provider versions with `~>`.
- [ ] `subscription_id` in the `provider` block comes from `var.default_subscription_id`.
- [ ] `main.tf` contains exactly one `module "defaults"` block, placed last.
- [ ] Module `source` is `"../.."` and nothing else.
- [ ] Every module argument group has a `# azurerm_<resource_type>` comment.
- [ ] ID lookup maps are built inline from supporting resource references.
- [ ] `default.auto.tfvars` has a section per resource type with the matching comment header.
- [ ] Map keys follow naming convention (named string or UUID v4).
- [ ] Optional configurations are commented-out with an explanation.
- [ ] One `outputs_<resource_type>.tf` file per resource type the module exposes.
- [ ] All outputs reference `module.defaults.<output_name>`.
- [ ] No hard-coded subscription IDs, tenant IDs, IP addresses, or secrets in tracked files.
- [ ] `data "http" "myip"` is used anywhere a caller IP is needed (Key Vault firewall, API server ACL).
