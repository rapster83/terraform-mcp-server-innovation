output "key_vault_key_ids" {
  description = "Map of Key Vault Key IDs keyed by the map key used in key_vault_keys."
  value       = module.defaults.key_vault_key_ids
}

output "key_vault_key_properties" {
  description = "Map of full Key Vault Key resource objects keyed by the map key used in key_vault_keys. Marked sensitive as it may expose cryptographic material."
  sensitive   = true
  value       = module.defaults.key_vault_key_properties
}
