variable "private_endpoints" {
  type = map(object({
    name                          = string
    resource_group_name           = optional(string, null)
    location                      = optional(string, null)
    subnet_id                     = string
    custom_network_interface_name = optional(string, null)

    private_service_connection = object({
      name                              = string
      is_manual_connection              = bool
      private_connection_resource_id    = optional(string, null)
      private_connection_resource_alias = optional(string, null)
      subresource_names                 = optional(list(string), null)
      request_message                   = optional(string, null)
    })

    private_dns_zone_group = optional(object({
      name                 = string
      private_dns_zone_ids = list(string)
    }), null)

    ip_configuration = optional(map(object({
      name               = string
      private_ip_address = string
      subresource_name   = optional(string, null)
      member_name        = optional(string, null)
    })), null)

    tags = optional(map(string), null)
  }))
  description = "Map of Private Endpoint configurations. Each entry creates one azurerm_private_endpoint resource. The map key is used as the Terraform resource identifier. resource_group_name and location fall back to module-level values when omitted."
  default     = {}
}
