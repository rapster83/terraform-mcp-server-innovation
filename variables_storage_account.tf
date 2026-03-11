variable "storage_account_access_tier" {
  type        = string
  description = "Defines the access tier for BlobStorage, FileStorage, and StorageV2 accounts. Valid options are Hot and Cool."
  default     = "Hot"
}

variable "storage_account_allow_nested_items_to_be_public" {
  type        = bool
  description = "Allow or disallow nested items within the account to opt into being public."
  default     = false
}

variable "storage_account_allowed_copy_scope" {
  type        = string
  description = "Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are AAD and PrivateLink."
  default     = null
}

variable "storage_account_azure_files_authentication" {
  type = object({
    directory_type                 = string
    default_share_level_permission = optional(string, null)
    active_directory = optional(object({
      domain_guid         = string
      domain_name         = string
      domain_sid          = optional(string, null)
      forest_name         = optional(string, null)
      netbios_domain_name = optional(string, null)
      storage_sid         = optional(string, null)
    }), null)
  })
  description = "Azure Files authentication configuration block for the Storage Account."
  default     = null
}

variable "storage_account_blob_properties" {
  type = object({
    change_feed_enabled           = optional(bool, false)
    change_feed_retention_in_days = optional(number, null)
    default_service_version       = optional(string, null)
    last_access_time_enabled      = optional(bool, false)
    versioning_enabled            = optional(bool, false)
    container_delete_retention_policy = optional(object({
      days = optional(number, 7)
    }), null)
    cors_rules = optional(map(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), null)
    delete_retention_policy = optional(object({
      days                     = optional(number, 7)
      permanent_delete_enabled = optional(bool, false)
    }), null)
    restore_policy = optional(object({
      days = number
    }), null)
  })
  description = "Blob service properties for the Storage Account."
  default     = null
}

variable "storage_account_create" {
  type        = bool
  description = "Whether to create the Storage Account."
  default     = false
}

variable "storage_account_provisioned_billing_model_version" {
  type        = string
  description = "Specifies the version of the provisioned billing model (e.g. when account_kind is FileStorage). Possible value is V2. Changing this forces a new resource to be created."
  default     = null
}

variable "storage_account_cross_tenant_replication_enabled" {
  type        = bool
  description = "Allow cross-tenant replication. Defaults to false."
  default     = false
}

variable "storage_account_custom_domain" {
  type = object({
    name          = string
    use_subdomain = optional(bool, null)
  })
  description = "A custom domain block to associate a custom domain name with the Storage Account."
  default     = null
}

variable "storage_account_customer_managed_key" {
  type = object({
    key_vault_key_id          = optional(string, null)
    user_assigned_identity_id = optional(string, null)
  })
  description = "Customer-managed key configuration for the Storage Account."
  default     = null
}

variable "storage_account_default_to_oauth_authentication" {
  type        = bool
  description = "Default to Azure Active Directory authorisation in the Azure portal when editing resources. Defaults to false."
  default     = false
}

variable "storage_account_dns_endpoint_type" {
  type        = string
  description = "Specifies which DNS endpoint type to use. Possible values are Standard and AzureDnsZone."
  default     = null
}

variable "storage_account_edge_zone" {
  type        = string
  description = "Specifies the Edge Zone within the Azure Region where this Storage Account should exist."
  default     = null
}

variable "storage_account_https_traffic_only_enabled" {
  type        = bool
  description = "Boolean flag which forces HTTPS if enabled. Defaults to true."
  default     = true
}

variable "storage_account_identity" {
  type = object({
    type         = optional(string, "UserAssigned")
    identity_ids = optional(list(string), [])
  })
  description = "Managed identity configuration for the Storage Account. Defaults to UserAssigned type."
  default     = null
}

variable "storage_account_immutability_policy" {
  type = object({
    allow_protected_append_writes = bool
    period_since_creation_in_days = number
    state                         = string
  })
  description = "Immutability policy configuration for the Storage Account."
  default     = null
}

variable "storage_account_infrastructure_encryption_enabled" {
  type        = bool
  description = "Enable infrastructure encryption (double encryption) at the storage service layer. Defaults to false."
  default     = false
}

variable "storage_account_is_hns_enabled" {
  type        = bool
  description = "Enable hierarchical namespace (Azure Data Lake Storage Gen2). Defaults to false."
  default     = false
}

variable "storage_account_kind" {
  type        = string
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage, and StorageV2. Defaults to StorageV2."
  default     = "StorageV2"
}

variable "storage_account_large_file_share_enabled" {
  type        = bool
  description = "Enable Large File Share. Defaults to false."
  default     = false
}

variable "storage_account_local_user_enabled" {
  type        = bool
  description = "Enable local user feature. Defaults to true."
  default     = true
}

variable "storage_account_min_tls_version" {
  type        = string
  description = "The minimum supported TLS version for the Storage Account. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2."
  default     = "TLS1_2"
}

variable "storage_account_name" {
  type        = string
  description = "Specifies the name of the Storage Account. Must be between 3 and 24 characters in length and use numbers and lower-case letters only. Required when storage_account_create is true."
  default     = null
}

variable "storage_account_network_rules" {
  type = object({
    bypass                     = optional(list(string), ["AzureServices"])
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
    private_link_accesses = optional(map(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string, null)
    })), null)
  })
  description = "Network rules configuration for the Storage Account."
  default     = null
}

variable "storage_account_nfsv3_enabled" {
  type        = bool
  description = "Enable NFSv3 protocol. Defaults to false."
  default     = false
}

variable "storage_account_public_network_access_enabled" {
  type        = bool
  description = "Whether the public network access is enabled for the Storage Account. Defaults to true."
  default     = true
}

variable "storage_account_queue_encryption_key_type" {
  type        = string
  description = "The encryption type of the queue service. Possible values are Service and Account."
  default     = null
}

variable "storage_account_queue_properties" {
  type = object({
    cors_rules = optional(map(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), null)
    hour_metrics = optional(object({
      enabled               = bool
      include_apis          = optional(bool, null)
      retention_policy_days = optional(number, null)
      version               = string
    }), null)
    logging = optional(object({
      delete                = bool
      read                  = bool
      retention_policy_days = optional(number, null)
      version               = string
      write                 = bool
    }), null)
    minute_metrics = optional(object({
      enabled               = bool
      include_apis          = optional(bool, null)
      retention_policy_days = optional(number, null)
      version               = string
    }), null)
  })
  description = "Queue service properties for the Storage Account."
  default     = null
}

variable "storage_account_replication_type" {
  type        = string
  description = "Defines the type of replication to use for this Storage Account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, and RAGZRS. Defaults to LRS."
  default     = "LRS"
}

variable "storage_account_routing" {
  type = object({
    choice                      = optional(string, "MicrosoftRouting")
    publish_internet_endpoints  = optional(bool, false)
    publish_microsoft_endpoints = optional(bool, false)
  })
  description = "Routing preferences configuration for the Storage Account."
  default     = null
}

variable "storage_account_sas_policy" {
  type = object({
    expiration_action = optional(string, "Log")
    expiration_period = string
  })
  description = "SAS policy configuration for the Storage Account."
  default     = null
}

variable "storage_account_sftp_enabled" {
  type        = bool
  description = "Enable SFTP for the Storage Account. Defaults to false."
  default     = false
}

variable "storage_account_share_properties" {
  type = object({
    cors_rules = optional(map(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), null)
    retention_policy = optional(object({
      days = optional(number, 7)
    }), null)
    smb = optional(object({
      authentication_types            = optional(list(string), null)
      channel_encryption_type         = optional(list(string), null)
      kerberos_ticket_encryption_type = optional(list(string), null)
      multichannel_enabled            = optional(bool, false)
      versions                        = optional(list(string), null)
    }), null)
  })
  description = "Azure Files share properties for the Storage Account."
  default     = null
}

variable "storage_account_shared_access_key_enabled" {
  type        = bool
  description = "Indicates whether the Storage Account permits requests to be authorised with the account access key. Defaults to true."
  default     = true
}

variable "storage_account_static_website" {
  type = object({
    error_404_document = optional(string, null)
    index_document     = optional(string, null)
  })
  description = "Static website hosting configuration for the Storage Account."
  default     = null
}

variable "storage_account_table_encryption_key_type" {
  type        = string
  description = "The encryption type of the table service. Possible values are Service and Account."
  default     = null
}

variable "storage_account_tags" {
  type        = map(string)
  description = "A mapping of tags to assign specifically to the Storage Account. Merged on top of module_tags."
  default     = null
}

variable "storage_account_tier" {
  type        = string
  description = "Defines the Tier to use for this Storage Account. Valid options are Standard and Premium. Defaults to Standard."
  default     = "Standard"
}

