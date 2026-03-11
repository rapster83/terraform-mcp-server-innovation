resource "azurerm_resource_group" "this" {
  count    = var.resource_group_create ? 1 : 0
  name     = var.resource_group_name
  location = var.module_location
  tags     = var.module_tags
}

resource "azurerm_storage_account" "this" {
  count = var.storage_account_create ? 1 : 0

  name                = var.storage_account_name
  resource_group_name = var.resource_group_create ? azurerm_resource_group.this[0].name : var.resource_group_name
  location            = var.module_location

  account_kind             = var.storage_account_kind
  account_replication_type = var.storage_account_replication_type
  account_tier             = var.storage_account_tier
  access_tier              = var.storage_account_access_tier

  provisioned_billing_model_version = var.storage_account_provisioned_billing_model_version
  allow_nested_items_to_be_public   = var.storage_account_allow_nested_items_to_be_public
  allowed_copy_scope                = var.storage_account_allowed_copy_scope
  cross_tenant_replication_enabled  = var.storage_account_cross_tenant_replication_enabled
  default_to_oauth_authentication   = var.storage_account_default_to_oauth_authentication
  dns_endpoint_type                 = var.storage_account_dns_endpoint_type
  edge_zone                         = var.storage_account_edge_zone
  https_traffic_only_enabled        = var.storage_account_https_traffic_only_enabled
  infrastructure_encryption_enabled = var.storage_account_infrastructure_encryption_enabled
  is_hns_enabled                    = var.storage_account_is_hns_enabled
  large_file_share_enabled          = var.storage_account_large_file_share_enabled
  local_user_enabled                = var.storage_account_local_user_enabled
  min_tls_version                   = var.storage_account_min_tls_version
  nfsv3_enabled                     = var.storage_account_nfsv3_enabled
  public_network_access_enabled     = var.storage_account_public_network_access_enabled
  queue_encryption_key_type         = var.storage_account_queue_encryption_key_type
  sftp_enabled                      = var.storage_account_sftp_enabled
  shared_access_key_enabled         = var.storage_account_shared_access_key_enabled
  table_encryption_key_type         = var.storage_account_table_encryption_key_type

  tags = local.storage_account_tags

  dynamic "custom_domain" {
    for_each = var.storage_account_custom_domain != null ? [var.storage_account_custom_domain] : []
    content {
      name          = custom_domain.value.name
      use_subdomain = custom_domain.value.use_subdomain
    }
  }

  dynamic "azure_files_authentication" {
    for_each = var.storage_account_azure_files_authentication != null ? [var.storage_account_azure_files_authentication] : []
    content {
      directory_type                 = azure_files_authentication.value.directory_type
      default_share_level_permission = azure_files_authentication.value.default_share_level_permission

      dynamic "active_directory" {
        for_each = azure_files_authentication.value.active_directory != null ? [azure_files_authentication.value.active_directory] : []
        content {
          domain_guid         = active_directory.value.domain_guid
          domain_name         = active_directory.value.domain_name
          domain_sid          = active_directory.value.domain_sid
          forest_name         = active_directory.value.forest_name
          netbios_domain_name = active_directory.value.netbios_domain_name
          storage_sid         = active_directory.value.storage_sid
        }
      }
    }
  }

  dynamic "blob_properties" {
    for_each = var.storage_account_blob_properties != null ? [var.storage_account_blob_properties] : []
    content {
      change_feed_enabled           = blob_properties.value.change_feed_enabled
      change_feed_retention_in_days = blob_properties.value.change_feed_retention_in_days
      default_service_version       = blob_properties.value.default_service_version
      last_access_time_enabled      = blob_properties.value.last_access_time_enabled
      versioning_enabled            = blob_properties.value.versioning_enabled

      dynamic "container_delete_retention_policy" {
        for_each = blob_properties.value.container_delete_retention_policy != null ? [blob_properties.value.container_delete_retention_policy] : []
        content {
          days = container_delete_retention_policy.value.days
        }
      }

      dynamic "cors_rule" {
        for_each = blob_properties.value.cors_rules != null ? blob_properties.value.cors_rules : {}
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "delete_retention_policy" {
        for_each = blob_properties.value.delete_retention_policy != null ? [blob_properties.value.delete_retention_policy] : []
        content {
          days                     = delete_retention_policy.value.days
          permanent_delete_enabled = delete_retention_policy.value.permanent_delete_enabled
        }
      }

      dynamic "restore_policy" {
        for_each = blob_properties.value.restore_policy != null ? [blob_properties.value.restore_policy] : []
        content {
          days = restore_policy.value.days
        }
      }
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.storage_account_customer_managed_key != null ? [var.storage_account_customer_managed_key] : []
    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  dynamic "identity" {
    for_each = var.storage_account_identity != null ? [var.storage_account_identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "immutability_policy" {
    for_each = var.storage_account_immutability_policy != null ? [var.storage_account_immutability_policy] : []
    content {
      allow_protected_append_writes = immutability_policy.value.allow_protected_append_writes
      period_since_creation_in_days = immutability_policy.value.period_since_creation_in_days
      state                         = immutability_policy.value.state
    }
  }

  dynamic "network_rules" {
    for_each = var.storage_account_network_rules != null ? [var.storage_account_network_rules] : []
    content {
      bypass                     = network_rules.value.bypass
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids

      dynamic "private_link_access" {
        for_each = network_rules.value.private_link_accesses != null ? network_rules.value.private_link_accesses : {}
        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id
          endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
        }
      }
    }
  }

  dynamic "queue_properties" {
    for_each = var.storage_account_queue_properties != null ? [var.storage_account_queue_properties] : []
    content {
      dynamic "cors_rule" {
        for_each = queue_properties.value.cors_rules != null ? queue_properties.value.cors_rules : {}
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "hour_metrics" {
        for_each = queue_properties.value.hour_metrics != null ? [queue_properties.value.hour_metrics] : []
        content {
          enabled               = hour_metrics.value.enabled
          include_apis          = hour_metrics.value.include_apis
          retention_policy_days = hour_metrics.value.retention_policy_days
          version               = hour_metrics.value.version
        }
      }

      dynamic "logging" {
        for_each = queue_properties.value.logging != null ? [queue_properties.value.logging] : []
        content {
          delete                = logging.value.delete
          read                  = logging.value.read
          retention_policy_days = logging.value.retention_policy_days
          version               = logging.value.version
          write                 = logging.value.write
        }
      }

      dynamic "minute_metrics" {
        for_each = queue_properties.value.minute_metrics != null ? [queue_properties.value.minute_metrics] : []
        content {
          enabled               = minute_metrics.value.enabled
          include_apis          = minute_metrics.value.include_apis
          retention_policy_days = minute_metrics.value.retention_policy_days
          version               = minute_metrics.value.version
        }
      }
    }
  }

  dynamic "routing" {
    for_each = var.storage_account_routing != null ? [var.storage_account_routing] : []
    content {
      choice                      = routing.value.choice
      publish_internet_endpoints  = routing.value.publish_internet_endpoints
      publish_microsoft_endpoints = routing.value.publish_microsoft_endpoints
    }
  }

  dynamic "sas_policy" {
    for_each = var.storage_account_sas_policy != null ? [var.storage_account_sas_policy] : []
    content {
      expiration_action = sas_policy.value.expiration_action
      expiration_period = sas_policy.value.expiration_period
    }
  }

  dynamic "share_properties" {
    for_each = var.storage_account_share_properties != null ? [var.storage_account_share_properties] : []
    content {
      dynamic "cors_rule" {
        for_each = share_properties.value.cors_rules != null ? share_properties.value.cors_rules : {}
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "retention_policy" {
        for_each = share_properties.value.retention_policy != null ? [share_properties.value.retention_policy] : []
        content {
          days = retention_policy.value.days
        }
      }

      dynamic "smb" {
        for_each = share_properties.value.smb != null ? [share_properties.value.smb] : []
        content {
          authentication_types            = smb.value.authentication_types
          channel_encryption_type         = smb.value.channel_encryption_type
          kerberos_ticket_encryption_type = smb.value.kerberos_ticket_encryption_type
          multichannel_enabled            = smb.value.multichannel_enabled
          versions                        = smb.value.versions
        }
      }
    }
  }

  dynamic "static_website" {
    for_each = var.storage_account_static_website != null ? [var.storage_account_static_website] : []
    content {
      error_404_document = static_website.value.error_404_document
      index_document     = static_website.value.index_document
    }
  }
}

resource "azurerm_key_vault_key" "this" {
  for_each = var.key_vault_keys

  name         = each.value.name
  key_vault_id = each.value.key_vault_id
  key_type     = each.value.key_type
  key_opts     = each.value.key_opts

  key_size        = each.value.key_size
  curve           = each.value.curve
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date

  tags = merge(var.module_tags, each.value.tags)

  dynamic "rotation_policy" {
    for_each = each.value.rotation_policy != null ? [each.value.rotation_policy] : []
    content {
      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry

      dynamic "automatic" {
        for_each = rotation_policy.value.automatic != null ? [rotation_policy.value.automatic] : []
        content {
          time_after_creation = automatic.value.time_after_creation
          time_before_expiry  = automatic.value.time_before_expiry
        }
      }
    }
  }
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                          = each.value.name
  resource_group_name           = coalesce(each.value.resource_group_name, var.resource_group_create ? azurerm_resource_group.this[0].name : var.resource_group_name)
  location                      = coalesce(each.value.location, var.module_location)
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = each.value.custom_network_interface_name

  tags = merge(var.module_tags, each.value.tags)

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : []
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  dynamic "private_service_connection" {
    for_each = [each.value.private_service_connection]
    content {
      name                              = private_service_connection.value.name
      is_manual_connection              = private_service_connection.value.is_manual_connection
      private_connection_resource_id    = private_service_connection.value.private_connection_resource_id
      private_connection_resource_alias = private_service_connection.value.private_connection_resource_alias
      subresource_names                 = private_service_connection.value.subresource_names
      request_message                   = private_service_connection.value.request_message
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations != null ? each.value.ip_configurations : {}
    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name
      member_name        = ip_configuration.value.member_name
    }
  }
}
