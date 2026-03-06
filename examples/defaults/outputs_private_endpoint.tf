output "private_endpoint_ids" {
  description = "Map of Private Endpoint IDs keyed by the map key used in private_endpoints."
  value       = module.defaults.private_endpoint_ids
}

output "private_endpoint_properties" {
  description = "Map of full Private Endpoint resource objects keyed by the map key used in private_endpoints."
  value       = module.defaults.private_endpoint_properties
}
