# Terraform Style Guide for Modules

> These instructions apply to all Terraform (`.tf`) files in this workspace.

---

## 1. Organisation & Registry

All modules **must** be feature-complete. Call for sub-modules are not allowed. Each module should be independently reusable and publishable to the Terraform Registry. 

---

## 2. Module conventions

### 2.1 Module names (registry)

- **azurerm modules:** hyphen-separated resource type, e.g. `cdn-frontdoor`, `postgresql-flexible`.
- **azuread modules:** hyphen-separated resource type, e.g. `group`, `service-principal`, `application`.
- **fabric modules:** single-word domain noun, e.g. `data`, `domain`, `event`, `spark`, `storage`. Exception: `machine_learning` (underscore preserved from Fabric API naming).
- VCS repository naming: `terraform-<provider>-<domain>` (e.g. `terraform-fabric-data`, `terraform-azurerm-kubernetes`, `terraform-azuread-group`).

### 2.2 Resource naming inside modules

All resources inside a module use `this` as the local name.

- Use `for_each` when multiple instances of a resource make sense (fan-out over a map or set):

```hcl
resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.kubernetes_cluster_node_pools
  ...
}
```

- Use `count` for single resource creation (typically toggled by a `_create` boolean flag):

```hcl
resource "azurerm_resource_group" "this" {
  count    = var.resource_group_create ? 1 : 0
  ...
}
```

### 2.3 Module README

```markdown
# terraform-<provider>-<domain>

One-line description of what the module manages.
```

---

## 3. Variable conventions

### 3.1 Naming

All variables use `snake_case`. The prefix is always the **full Terraform resource type** (without the provider prefix), followed by the attribute or sub-resource.

```
<resource_type>_<attribute>
```

Examples:
```
kubernetes_cluster_node_pools
kubernetes_cluster_network_profiles
postgresql_flexible_server_maintenance_windows
cdn_frontdoor_profile_identities
```

Cross-resource reference maps follow:
```
<sub_resource>_<lookup_resource>_ids
```

Examples:
```
eventstream_workspace_ids       # map(string) of workspace IDs for eventstreams
kql_database_eventhouse_ids     # map(string) of eventhouse IDs for KQL databases
key_vault_certificate_key_vault_ids
```

Module-level location/region: use `module_location` (azurerm modules) or `location`.
Module-level tags: use `module_tags` or `tags`. Per-resource tags: `<resource_type>_tags`.

### 3.2 Variable types

| Pattern | Use when |
|---------|----------|
| `string` | Single scalar value |
| `bool` | Feature flag |
| `number` | Numeric scalar |
| `list(string)` | Ordered list of strings |
| `map(string)` | Key-value lookup map (e.g. IDs) |
| `map(object({...}))` | Complex, fan-out resource configuration |

**Always** wrap object attributes in `optional(type, default)` to allow callers to omit fields:

### 3.3 Variable attribute order

Within every `variable` block, meta-arguments must appear in this fixed order:

```
type → description → sensitive → default
```

Omit `sensitive` when it is not needed; never change the relative order of the remaining attributes.

```hcl
# ✅ correct order
variable "kubernetes_cluster_node_pools" {
  type = map(object({
    vm_size                 = optional(string, null)
    auto_scaling_enabled    = optional(bool, true)
    host_encryption_enabled = optional(bool, true)
    node_public_ip_enabled  = optional(bool, false)
    os_disk_size_gb         = optional(number, 50)
    os_disk_type            = optional(string, "Managed")
    tags                    = optional(map(string), null)
    # nested optional block
    kubelet_configs = optional(map(object({
      cpu_manager_policy    = optional(string, null)
      cpu_cfs_quota_enabled = optional(bool, true)
    })), null)
  }))
  description = "Map of Node Pool configurations for the Kubernetes Cluster."
  default     = null
}

variable "my_secret_value" {
  type        = string
  description = "A sensitive value passed to the module."
  sensitive   = true
  default     = null
}
```

### 3.4 Boolean creation flags

Use the `_create` suffix to control whether a resource is created:

| Suffix | Meaning | Example |
|--------|---------|--------|
| `_create` | Controls resource creation | `postgresql_flexible_server_create`, `resource_group_create` |

Boolean `_create` flags default to `false` (opt-in).

### 3.5 Required vs optional

- Variables that have no sensible default **must** be required (no `default`).
- All variables must have a `description`.
- Optional variables that have a provider-documented default value must use that value as their `default`. If no provider default exists, set `default = null`.

### 3.6 Variable ordering

Variables inside a `variables_<resource_type>.tf` file **must** follow the exact argument order listed in the official Terraform provider documentation for that resource type:

1. **Required arguments** — in the order they appear in the docs *Required Arguments* section.
2. **Optional arguments** — in the order they appear in the docs *Optional Arguments* section.
3. **Block / nested-object arguments** — in the order they appear in the docs, after all scalar arguments.

> Use the `mcp_terraform_pub_get_provider_details` tool to retrieve the canonical argument list and ordering for a given resource type before writing or reviewing variables.

```hcl
# ✅ Matches provider-docs argument order for azurerm_storage_account
variable "storage_account_name" { ... }                    # required — 1st in docs
variable "storage_account_resource_group_name" { ... }     # required — 2nd in docs
variable "storage_account_location" { ... }                # required — 3rd in docs
variable "storage_account_account_tier" { ... }            # required — 4th in docs
variable "storage_account_account_replication_type" { ... } # required — 5th in docs
# … optional scalars in docs order …
variable "storage_account_blob_properties" { ... }         # block — after all scalars
```

> ❌ **Do not** sort variables alphabetically — alphabetical order diverges from the provider docs and makes cross-referencing harder.

```hcl
# ✅ required — no default
variable "module_location" {
  type        = string
  description = "The Azure region where the resource group should exist."
}

# ✅ optional — provider default documented in description
variable "postgresql_flexible_server_backup_retention_days" {
  type        = number
  description = "The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days."
  default     = 7
}

# ✅ optional — no provider default, use null
variable "postgresql_flexible_server_zone" {
  type        = string
  description = "Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located."
  default     = null
}

# ✅ sensitive variable — sensitive between description and default
variable "postgresql_flexible_server_admin_password" {
  type        = string
  description = "The administrator password for the PostgreSQL Flexible Server."
  sensitive   = true
  default     = null
}
```

---

## 4. Output conventions

### 4.1 Naming

| Pattern | Use when |
|---------|----------|
| `<resource_type>_id` | Single resource ID |
| `<resource_type>_ids` | Map of resource IDs (from for_each) |
| `<resource_type>_properties` | Full resource attributes object |
| `<resource_type>_properties_<sub_attr>` | Specific nested property |

Examples:
```hcl
output "kubernetes_cluster_id"   { ... }   # single
output "lakehouse_ids"            { ... }   # fan-out map
output "warehouse_properties"     { ... }   # full object
output "lakehouse_properties_sql_endpoint_properties" { ... }  # nested
```

All outputs must include a `description`.

### 4.2 Output attribute order

Within every `output` block, meta-arguments must appear in this fixed order:

```
description → sensitive → value
```

Omit `sensitive` when not needed; never change the relative order of the remaining attributes.

```hcl
# ✅ non-sensitive output
output "kubernetes_cluster_id" {
  description = "The ID of the Kubernetes Cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

# ✅ sensitive output — sensitive between description and value
output "kubernetes_cluster_kube_config" {
  description = "The raw kubeconfig file for the Kubernetes Cluster."
  sensitive   = true
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
}
```

---

## 5. Provider conventions

### 5.1 Required providers

Pin providers to an exact version in `versions.tf` (or `terraform.tf`):

```hcl
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    fabric = {
      source  = "microsoft/fabric"
      version = "0.1.0-beta.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
```

### 5.2 Provider grouping

- **azurerm** — all Azure infrastructure (AKS, CDN Front Door, PostgreSQL Flexible Server, networking).
- **fabric** — all Microsoft Fabric resources (lakehouses, warehouses, KQL databases, eventhouses, eventstreams, ML experiments, ML models, domains, Spark pools).

---

## 6. File layout

Each workspace / configuration follows this file structure:

```
.
├── main.tf                              # module calls only — no raw resources
├── locals.tf                            # exactly one locals block (optional)
├── data.tf                              # all data sources (optional)
├── variables_<resource_type>.tf         # one file per resource type, e.g.:
│   ├── variables_kubernetes_cluster.tf
│   ├── variables_resource_group.tf
│   └── variables_postgresql_flexible_server.tf
├── outputs_<resource_type>.tf           # one file per resource type, e.g.:
│   ├── outputs_kubernetes_cluster.tf
│   └── outputs_postgresql_flexible_server.tf
├── versions.tf                          # terraform block + required_providers
└── README.md
```

- **`main.tf`** must contain only `module` blocks. No raw `resource` blocks — use private modules instead.
- If locals are needed, they live in **`locals.tf`** as a single `locals` block. No `locals` blocks anywhere else.
- Variables and outputs are split into **one file per resource type**, named `variables_<resource_type>.tf` and `outputs_<resource_type>.tf`. Within each file, variable declarations **follow the argument order in the official Terraform provider documentation** for that resource type (see §3.5).
- The `<resource_type>` token matches the Terraform resource type without the provider prefix (e.g. `kubernetes_cluster`, `resource_group`, `postgresql_flexible_server`).

#### 6.1 Attribute ordering inside resource blocks

Attributes and nested blocks inside every `resource` block in `main.tf` (or any other `.tf` file) **must** match the argument order in the official Terraform provider documentation for that resource type:

1. **Required arguments** — in docs order.
2. **Optional scalar arguments** — in docs order, after all required arguments.
3. **`tags`** — always the last scalar attribute, immediately before any blocks.
4. **Dynamic / nested blocks** — in docs order, after all scalar arguments.

```hcl
# ✅ Attribute order matches azurerm_storage_account provider docs
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = ...
  location                 = var.module_location
  account_tier             = var.storage_account_account_tier
  account_replication_type = var.storage_account_account_replication_type
  access_tier              = var.storage_account_access_tier
  account_kind             = var.storage_account_kind
  allow_nested_items_to_be_public = var.storage_account_allow_nested_items_to_be_public
  tags = local.storage_account_tags

  dynamic "blob_properties" { ... }
  dynamic "network_rules"   { ... }
}
```

> Use the `mcp_terraform_pub_get_provider_details` tool to retrieve the canonical argument ordering before writing or reviewing a resource block.

---

## 7. Identity & security

- Prefer **UserAssigned** managed identities (`type = "UserAssigned"`) — the default in all private modules.
- Never hard-code secrets or passwords. Use Key Vault secret references or `random_password` variables with `_wo` (write-only) variants.

---

## 8. Deprecated attributes

- **Never** include attributes or blocks marked as deprecated in the official Terraform provider documentation.
- Before writing or reviewing any resource block or variable file, check the provider docs for deprecation notices using the `mcp_terraform_pub_get_provider_details` tool.
