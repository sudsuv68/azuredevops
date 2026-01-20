resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

locals {
  # If zoned_subnets=true, we create tier-az1 and tier-az2 subnets (8 total)
  # Otherwise we create 4 subnets total (tier only)
  subnet_defs = var.zoned_subnets ? merge(
    {
      workload_az1 = var.subnets.workload_az1
      workload_az2 = var.subnets.workload_az2
      db_az1       = var.subnets.db_az1
      db_az2       = var.subnets.db_az2
      web_az1      = var.subnets.web_az1
      web_az2      = var.subnets.web_az2
      mgmt_az1     = var.subnets.mgmt_az1
      mgmt_az2     = var.subnets.mgmt_az2
    },
    {}
    ) : {
    workload = var.subnets.workload
    db       = var.subnets.db
    web      = var.subnets.web
    mgmt     = var.subnets.mgmt
  }
}

resource "azurerm_subnet" "this" {
  for_each             = local.subnet_defs
  name                 = "${var.subnet_name_prefix}-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  # Optional: keep simple - add endpoints or delegations later
  service_endpoints = each.value.service_endpoints
}

# -----------------------
# NAT Gateway (optional)
# -----------------------
resource "azurerm_public_ip" "nat" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "${var.vnet_name}-nat-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "${var.vnet_name}-natgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count                = var.enable_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

#Attach NAT to private subnets: workload + db (and their zoned variants)
locals {
  private_subnet_keys = var.zoned_subnets ? ["workload_az1", "workload_az2", "db_az1", "db_az2"] : ["workload", "db"]

}

resource "azurerm_subnet_nat_gateway_association" "private" {
  for_each       = var.enable_nat_gateway ? toset(local.private_subnet_keys) : toset([])
  subnet_id      = azurerm_subnet.this[each.value].id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}

# -----------------------
# NSGs
# -----------------------
resource "azurerm_network_security_group" "workload" {
  name                = "${var.vnet_name}-nsg-workload"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "db" {
  name                = "${var.vnet_name}-nsg-db"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "web" {
  name                = "${var.vnet_name}-nsg-web"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "mgmt" {
  name                = "${var.vnet_name}-nsg-mgmt"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# -----------------------
# NSG rules (opinionated defaults)
# -----------------------

# Web: allow inbound 80/443 from Internet
resource "azurerm_network_security_rule" "web_in_http_https" {
  #for_each                    = toset(var.web_inbound_ports)
  for_each                    = toset([for port in var.web_inbound_ports: tostring(port)])
  name                        = "allow-internet-${each.value}"
  priority                    = 100 + index(var.web_inbound_ports, tonumber(each.value))
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = tostring(each.value)
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web.name
}

# DB: allow from workload subnet(s) to DB ports
resource "azurerm_network_security_rule" "db_from_workload" {
  #for_each                    = toset(var.db_ports)
  for_each = toset([for port in var.db_ports : tostring(port)])

  name                        = "allow-workload-db-${each.value}"
  priority                    = 200 + index(var.db_ports, tonumber(each.value))
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = tostring(each.value)
  source_address_prefixes     = local.workload_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db.name
}

# Mgmt: allow inbound from your corp IPs (e.g. office/VPN)
resource "azurerm_network_security_rule" "mgmt_from_corp" {
  for_each                    = toset(var.mgmt_inbound_cidrs)
  name                        = "allow-corp-${replace(each.value, "/", "-")}"
  priority                    = 300 + index(var.mgmt_inbound_cidrs, each.value)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = each.value
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.mgmt.name
}

# Workload: no explicit Internet inbound allow rules added (secure default).
# Azure NSG default rules allow VNet inbound; you can tighten further if desired.

# -----------------------
# NSG Associations
# -----------------------
locals {
  workload_subnet_keys = var.zoned_subnets ? ["workload_az1", "workload_az2"] : ["workload"]
  db_subnet_keys       = var.zoned_subnets ? ["db_az1", "db_az2"] : ["db"]
  web_subnet_keys      = var.zoned_subnets ? ["web_az1", "web_az2"] : ["web"]
  mgmt_subnet_keys     = var.zoned_subnets ? ["mgmt_az1", "mgmt_az2"] : ["mgmt"]
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  for_each                  = toset(local.workload_subnet_keys)
  subnet_id                 = azurerm_subnet.this[each.value].id
  network_security_group_id = azurerm_network_security_group.workload.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  for_each                  = toset(local.db_subnet_keys)
  subnet_id                 = azurerm_subnet.this[each.value].id
  network_security_group_id = azurerm_network_security_group.db.id
}

resource "azurerm_subnet_network_security_group_association" "web" {
  for_each                  = toset(local.web_subnet_keys)
  subnet_id                 = azurerm_subnet.this[each.value].id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "mgmt" {
  for_each                  = toset(local.mgmt_subnet_keys)
  subnet_id                 = azurerm_subnet.this[each.value].id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

#Compute workload subnet prefixes used by DB rule (depends on zoned mode)
locals {
  workload_prefixes = var.zoned_subnets  ? concat(
        try(azurerm_subnet.this["workload_az1"].address_prefixes,[]),
        try(azurerm_subnet.this["workload_az2"].address_prefixes,[])
      )    : try(azurerm_subnet.this["workload"].address_prefixes,[])
}
