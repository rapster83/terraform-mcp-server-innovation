output "private_endpoint_ids" {
  description = "Map of Private Endpoint IDs keyed by the map key used in private_endpoints."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_properties" {
  description = "Map of full Private Endpoint resource objects keyed by the map key used in private_endpoints."
  value       = { for k, v in azurerm_private_endpoint.this : k => v }
}
