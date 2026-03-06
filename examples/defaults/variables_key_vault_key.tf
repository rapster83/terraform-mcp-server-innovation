variable "key_vault_keys" {
  type = map(object({
    name         = string
    key_vault_id = optional(string, null)
    key_type     = string
    key_opts     = list(string)

    key_size        = optional(number, null)
    curve           = optional(string, null)
    not_before_date = optional(string, null)
    expiration_date = optional(string, null)
    tags            = optional(map(string), null)

    rotation_policy = optional(object({
      expire_after         = optional(string, null)
      notify_before_expiry = optional(string, null)
      automatic = optional(object({
        time_after_creation = optional(string, null)
        time_before_expiry  = optional(string, null)
      }), null)
    }), null)
  }))
  description = "Map of Key Vault Key configurations. Each entry creates one azurerm_key_vault_key resource. The map key is used as the Terraform resource identifier. key_vault_id is resolved at runtime from the supporting azurerm_key_vault resource."
  default     = {}
}
