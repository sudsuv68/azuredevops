resource "azurerm_resource_group" "this" {
  name     = "rg-net-dev"
  location = "australiaeast"

  tags = {
    env = "dev"
  }
}

module "vnet" {
  source              = "../mainmodule"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vnet_name           = "vnet-dev"
  vnet_address_space  = ["10.10.0.0/16"]

  zoned_subnets = false

  subnets = {
    workload = {
      address_prefixes  = ["10.10.1.0/24"]
      service_endpoints = []
    }
    db = {
      address_prefixes  = ["10.10.2.0/24"]
      service_endpoints = []
    }
    web = {
      address_prefixes  = ["10.10.3.0/24"]
      service_endpoints = []
    }
    mgmt = {
      address_prefixes  = ["10.10.4.0/24"]
      service_endpoints = []
    }
  }

  db_ports            = [1433]
  web_inbound_ports   = [80, 443]
  mgmt_inbound_cidrs  = ["203.0.113.10/32"] # replace with your VPN/office IPs
  enable_nat_gateway  = true

  tags = {
    env = "dev"
  }
}
