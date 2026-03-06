# terraform-azurerm-storage-account

Manages one or more Azure Storage Accounts, with optional Resource Group creation.

## Usage

```hcl
module "storage_account" {
  source = "git::https://github.com/my-org/terraform-azurerm-storage-account.git"

  module_location = "uksouth"
  module_tags     = { environment = "production", team = "platform" }

  resource_group_create = true
  resource_group_name   = "rg-storage-prod"

  storage_accounts = {
    analytics = {
      name                          = "stanalyticsproduks001"
      account_tier                  = "Standard"
      account_replication_type      = "ZRS"
      is_hns_enabled                = true
      public_network_access_enabled = false

      identity = {
        type         = "UserAssigned"
        identity_ids = ["/subscriptions/.../userAssignedIdentities/mi-storage"]
      }

      network_rules = {
        default_action             = "Deny"
        bypass                     = ["AzureServices"]
        virtual_network_subnet_ids = ["/subscriptions/.../subnets/snet-storage"]
      }

      blob_properties = {
        versioning_enabled = true
        delete_retention_policy = {
          days = 30
        }
        container_delete_retention_policy = {
          days = 30
        }
      }
    }
  }
}
```

## Features

- Fan-out creation of multiple Storage Accounts via a single `storage_accounts` map.
- Optional Resource Group creation controlled by `resource_group_create`.
- Per-resource tag override merged on top of module-level `module_tags`.
- Full coverage of all `azurerm_storage_account` configuration blocks:
  - Blob properties (versioning, change feed, CORS, soft delete, restore)
  - Share properties (Azure Files SMB, CORS, soft delete)
  - Queue properties (logging, hour/minute metrics, CORS)
  - Static website hosting
  - Network rules and private link access
  - Customer-managed keys (Key Vault and Managed HSM)
  - Managed identity (UserAssigned preferred)
  - Azure Files AD/AADDS authentication
  - Immutability policies and SAS policies
  - Routing preferences

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| azurerm | ~> 4.0 |

## Inputs

### Module-level

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `module_location` | `string` | yes | Azure region for all resources. |
| `module_tags` | `map(string)` | no | Tags applied to every resource; per-resource tags are merged on top. |

### Resource Group

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `resource_group_create` | `bool` | `false` | Create the Resource Group when `true`. |
| `resource_group_name` | `string` | — | Name of the Resource Group (created or pre-existing). |

### Storage Accounts

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `storage_accounts` | `map(object)` | `null` | Map of Storage Account configurations. See variable definition for full schema. |

Key attributes within each `storage_accounts` entry:

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `string` | — | Storage account name (3–24 lowercase alphanumeric characters). |
| `account_kind` | `string` | `"StorageV2"` | BlobStorage, BlockBlobStorage, FileStorage, Storage, or StorageV2. |
| `account_tier` | `string` | `"Standard"` | Standard or Premium. |
| `account_replication_type` | `string` | `"LRS"` | LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS. |
| `access_tier` | `string` | `"Hot"` | Hot or Cool (BlobStorage and StorageV2 only). |
| `https_traffic_only_enabled` | `bool` | `true` | Enforce HTTPS-only traffic. |
| `min_tls_version` | `string` | `"TLS1_2"` | Minimum TLS version. |
| `public_network_access_enabled` | `bool` | `true` | Allow public network access. |
| `shared_access_key_enabled` | `bool` | `true` | Allow access with account key. |
| `infrastructure_encryption_enabled` | `bool` | `false` | Enable double encryption at the infrastructure layer. |
| `is_hns_enabled` | `bool` | `false` | Enable hierarchical namespace (Data Lake Storage Gen2). |
| `sftp_enabled` | `bool` | `false` | Enable SFTP support. |
| `identity` | `object` | `null` | Managed identity block; defaults to `UserAssigned`. |
| `blob_properties` | `object` | `null` | Blob service settings. |
| `network_rules` | `object` | `null` | Network ACL settings; defaults `default_action = "Deny"`. |
| `customer_managed_key` | `object` | `null` | Customer-managed key configuration. |

## Outputs

| Name | Sensitive | Description |
|------|-----------|-------------|
| `resource_group_id` | no | ID of the created Resource Group, or `null`. |
| `storage_account_ids` | no | Map of Storage Account IDs keyed by map key. |
| `storage_account_properties` | **yes** | Full resource objects (includes connection strings and keys). |
| `storage_account_properties_identity` | no | Managed identity blocks per account. |
| `storage_account_properties_primary_blob_endpoints` | no | Primary Blob endpoints per account. |
| `storage_account_properties_primary_dfs_endpoints` | no | Primary DFS (ADLS Gen2) endpoints per account. |
| `storage_account_properties_primary_file_endpoints` | no | Primary File endpoints per account. |
| `storage_account_properties_primary_queue_endpoints` | no | Primary Queue endpoints per account. |
| `storage_account_properties_primary_table_endpoints` | no | Primary Table endpoints per account. |
| `storage_account_properties_primary_web_endpoints` | no | Primary static web endpoints per account. |
