#provider "azurerm" {
#  features {}
#}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  # good defaults
  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = var.tags
}
