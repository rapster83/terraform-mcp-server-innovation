# Section 1 — Supporting / prerequisite resources

resource "azurerm_resource_group" "rg_st_weu_dev_01" {
  name     = var.resource_group_name
  location = var.module_location
  tags     = var.module_tags
}

resource "azurerm_key_vault" "kv_st_weu_dev_01" {
  name                = "kv-st-weu-dev-01"
  location            = var.module_location
  resource_group_name = azurerm_resource_group.rg_st_weu_dev_01.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [trimspace(data.http.myip.response_body)]
  }

  tags = var.module_tags
}

resource "azurerm_role_assignment" "kv_st_weu_dev_01_crypto_officer" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Crypto Officer"
  scope                = azurerm_key_vault.kv_st_weu_dev_01.id
}

resource "azurerm_virtual_network" "vnet_st_weu_dev_01" {
  name                = "vnet-st-weu-dev-01"
  location            = var.module_location
  resource_group_name = azurerm_resource_group.rg_st_weu_dev_01.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.module_tags
}

resource "azurerm_subnet" "snet_st_weu_dev_01" {
  name                 = "snet-st-weu-dev-01"
  resource_group_name  = azurerm_resource_group.rg_st_weu_dev_01.name
  virtual_network_name = azurerm_virtual_network.vnet_st_weu_dev_01.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "pdnsz_vaultcore" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg_st_weu_dev_01.name
  tags                = var.module_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "pdnsz_vaultcore_link" {
  name                  = "pdnsz-vaultcore-vnet-link"
  resource_group_name   = azurerm_resource_group.rg_st_weu_dev_01.name
  private_dns_zone_name = azurerm_private_dns_zone.pdnsz_vaultcore.name
  virtual_network_id    = azurerm_virtual_network.vnet_st_weu_dev_01.id
  tags                  = var.module_tags
}

# Section 2 — Module call

module "defaults" {
  depends_on = [azurerm_role_assignment.kv_st_weu_dev_01_crypto_officer]
  source     = "../.."

  # globals
  module_location = var.module_location
  module_tags     = var.module_tags

  # azurerm_resource_group
  resource_group_create = var.resource_group_create
  resource_group_name   = var.resource_group_name

  # azurerm_storage_account
  storage_account_create                        = var.storage_account_create
  storage_account_name                          = var.storage_account_name
  storage_account_tier                          = var.storage_account_tier
  storage_account_replication_type              = var.storage_account_replication_type
  storage_account_public_network_access_enabled = var.storage_account_public_network_access_enabled

  # azurerm_key_vault_key
  key_vault_keys = local.key_vault_keys

  # azurerm_private_endpoint
  private_endpoints = local.private_endpoints
}
