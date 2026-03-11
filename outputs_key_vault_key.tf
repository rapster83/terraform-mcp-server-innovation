output "key_vault_key_ids" {
  description = "Map of Key Vault Key IDs keyed by the map key used in key_vault_keys."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.id }
}

output "key_vault_key_properties" {
  description = "Map of full Key Vault Key resource objects keyed by the map key used in key_vault_keys. Marked sensitive as it may expose cryptographic material."
  sensitive   = true
  value       = { for k, v in azurerm_key_vault_key.this : k => v }
}

output "key_vault_key_properties_resource_id" {
  description = "Map of versioned Key Vault Key resource IDs. Points to a specific version; does not auto-rotate in other Azure services."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.resource_id }
}

output "key_vault_key_properties_resource_versionless_id" {
  description = "Map of versionless Key Vault Key resource IDs. Allows other Azure services that support it to auto-rotate their value when the key is updated."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.resource_versionless_id }
}

output "key_vault_key_properties_version" {
  description = "Map of current versions of the Key Vault Keys."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.version }
}

output "key_vault_key_properties_versionless_id" {
  description = "Map of base (versionless) IDs of the Key Vault Keys."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.versionless_id }
}

output "key_vault_key_properties_public_key_pem" {
  description = "Map of PEM-encoded public keys of the Key Vault Keys."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.public_key_pem }
}

output "key_vault_key_properties_public_key_openssh" {
  description = "Map of OpenSSH-encoded public keys of the Key Vault Keys."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.public_key_openssh }
}
