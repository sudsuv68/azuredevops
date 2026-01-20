output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  value = { for k, s in azurerm_subnet.this : k => s.id }
}

output "nsg_ids" {
  value = {
    workload = azurerm_network_security_group.workload.id
    db       = azurerm_network_security_group.db.id
    web      = azurerm_network_security_group.web.id
    mgmt     = azurerm_network_security_group.mgmt.id
  }
}
