output "resource_group_id" {
  description = "The ID of the Resource Group created by this module. Returns null when `resource_group_create` is false."
  value       = module.defaults.resource_group_id
}
