variable "default_subscription_id" {
  type        = string
  description = "The Azure Subscription ID where the resources should be created. Changing this forces a new resource to be created."
}

variable "module_location" {
  description = "The Azure region where the resources should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "westeurope"
}

variable "module_tags" {
  description = "A mapping of tags which should be assigned to all resources of the module."
  type        = map(string)
  default     = null
}
