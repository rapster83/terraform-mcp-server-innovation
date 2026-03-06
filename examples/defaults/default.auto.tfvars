# globals
default_subscription_id = "70f0d042-bb3d-490b-8498-964903cd415a"
module_tags = {
  environment = "dev"
  managed_by  = "terraform"
}

# azurerm_resource_group
resource_group_name = "rg-st-weu-dev-01"

# azurerm_storage_account
storage_account_create                        = true
storage_account_name                          = "ststweudev01"
storage_account_public_network_access_enabled = false

# azurerm_key_vault_key
key_vault_keys = {
  key-st-weu-dev-01 = {
    name            = "key-st-weu-dev-01"
    key_type        = "RSA"
    key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
    key_size        = 2048
    expiration_date = "2027-01-01T00:00:00Z"
    rotation_policy = {
      expire_after         = "P180D"
      notify_before_expiry = "P30D"
      automatic = {
        time_before_expiry = "P14D"
      }
    }
  }
}

# azurerm_private_endpoint
private_endpoints = {
  pep-kv-st-weu-dev-01 = {
    name = "pep-kv-st-weu-dev-01"
    private_service_connection = {
      name                 = "psc-kv-st-weu-dev-01"
      is_manual_connection = false
      subresource_names    = ["vault"]
    }
    private_dns_zone_group = {
      name = "pdnsz-kv-st-weu-dev-01"
    }
  }
}
