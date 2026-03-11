output "private_endpoint_ids" {
  description = "Map of Private Endpoint IDs keyed by the map key used in private_endpoints."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_properties" {
  description = "Map of full Private Endpoint resource objects keyed by the map key used in private_endpoints."
  value       = { for k, v in azurerm_private_endpoint.this : k => v }
}

output "private_endpoint_properties_network_interface" {
  description = "Map of network interface blocks (id, name) for each Private Endpoint."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.network_interface }
}

output "private_endpoint_properties_private_service_connection" {
  description = "Map of private service connection blocks for each Private Endpoint. Contains the computed private_ip_address."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.private_service_connection }
}

output "private_endpoint_properties_custom_dns_configs" {
  description = "Map of custom DNS config blocks (fqdn, ip_addresses) for each Private Endpoint."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.custom_dns_configs }
}
