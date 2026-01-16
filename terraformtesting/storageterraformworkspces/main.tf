resource "azurerm_resource_group" "rg" {
  name     = local.current.resource_group_name
  location = local.current.location
  tags     = local.current.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = local.current.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = local.current.tags
}
