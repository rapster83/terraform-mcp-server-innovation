data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}
