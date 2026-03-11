variable "module_location" {
  type        = string
  description = "The Azure region where all resources in this module will be created."
}

variable "module_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to all resources managed by this module. Per-resource tags are merged on top of these."
  default     = null
}
