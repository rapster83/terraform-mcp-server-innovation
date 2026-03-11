variable "resource_group_create" {
  type        = bool
  description = "Whether to create the Resource Group. If false, the resource group referenced by `resource_group_name` must already exist."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which to create all storage accounts. When `resource_group_create` is true, this name is used for the new Resource Group."
}
