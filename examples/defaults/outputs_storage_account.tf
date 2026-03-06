output "storage_account_id" {
  description = "The ID of the Storage Account. Returns null when storage_account_create is false."
  value       = module.defaults.storage_account_id
}

output "storage_account_properties" {
  description = "The full Storage Account resource object. Marked sensitive because it includes connection strings and access keys. Returns null when storage_account_create is false."
  value       = module.defaults.storage_account_properties
  sensitive   = true
}

output "storage_account_properties_identity" {
  description = "The managed identity block of the Storage Account. Returns null when storage_account_create is false."
  value       = module.defaults.storage_account_properties_identity
}

output "storage_account_properties_primary_blob_endpoint" {
  description = "The primary Blob service endpoint of the Storage Account. Returns null when storage_account_create is false."
  value       = module.defaults.storage_account_properties_primary_blob_endpoint
}

output "storage_account_properties_primary_dfs_endpoint" {
  description = "The primary Data Lake Storage Gen2 (DFS) endpoint of the Storage Account. Returns null when storage_account_create is false."
  value       = module.defaults.storage_account_properties_primary_dfs_endpoint
}

output "storage_account_properties_primary_file_endpoint" {
  description = "The primary Azure Files endpoint of the Storage Account. Returns null when storage_account_create is false."
  value       = module.defaults.storage_account_properties_primary_file_endpoint
}

output "storage_account_properties_primary_queue_endpoint" {
  description = "The primary Queue service endpoint of the Storage Account. Returns null when storage_account_create is false."
  value       = module.defaults.storage_account_properties_primary_queue_endpoint
}

output "storage_account_properties_primary_table_endpoint" {
  description = "The primary Table service endpoint of the Storage Account. Returns null when storage_account_create is false."
  value       = module.defaults.storage_account_properties_primary_table_endpoint
}

output "storage_account_properties_primary_web_endpoint" {
  description = "The primary static website endpoint of the Storage Account. Returns null when storage_account_create is false."
  value       = module.defaults.storage_account_properties_primary_web_endpoint
}
