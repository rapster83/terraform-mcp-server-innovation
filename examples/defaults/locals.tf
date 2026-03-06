locals {
  key_vault_keys = {
    for k, v in var.key_vault_keys : k => merge(v, {
      key_vault_id = azurerm_key_vault.kv_st_weu_dev_01.id
    })
  }

  private_endpoints = {
    for k, v in var.private_endpoints : k => merge(v, {
      subnet_id = azurerm_subnet.snet_st_weu_dev_01.id
      private_service_connection = merge(v.private_service_connection, {
        private_connection_resource_id = azurerm_key_vault.kv_st_weu_dev_01.id
      })
      private_dns_zone_group = v.private_dns_zone_group != null ? {
        name                 = v.private_dns_zone_group.name
        private_dns_zone_ids = [azurerm_private_dns_zone.pdnsz_vaultcore.id]
      } : null
    })
  }
}
