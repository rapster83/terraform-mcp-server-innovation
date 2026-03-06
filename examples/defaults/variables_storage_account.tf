variable "storage_account_create" {
  type        = bool
  description = "Whether to create the Storage Account."
  default     = false
}

variable "storage_account_name" {
  type        = string
  description = "Specifies the name of the Storage Account. Must be between 3 and 24 characters in length and use numbers and lower-case letters only. Required when storage_account_create is true."
  default     = null
}

variable "storage_account_public_network_access_enabled" {
  type        = bool
  description = "Whether the public network access is enabled for the Storage Account. Defaults to true."
  default     = true
}

variable "storage_account_replication_type" {
  type        = string
  description = "Defines the type of replication to use for this Storage Account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, and RAGZRS. Defaults to LRS."
  default     = "LRS"
}

variable "storage_account_tier" {
  type        = string
  description = "Defines the Tier to use for this Storage Account. Valid options are Standard and Premium. Defaults to Standard."
  default     = "Standard"
}
