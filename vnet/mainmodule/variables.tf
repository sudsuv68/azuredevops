variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnet_name_prefix" {
  type    = string
  default = "snet"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# If false: expects 4 subnets (workload, db, web, mgmt)
# If true: expects 8 subnets (tier split across az1 + az2)
variable "zoned_subnets" {
  type    = bool
  default = false
}

# Subnet input object supports both modes.
# In non-zoned mode, set: workload/db/web/mgmt
# In zoned mode, set: workload_az1, workload_az2, db_az1, db_az2, web_az1, web_az2, mgmt_az1, mgmt_az2
variable "subnets" {
  type = any
}

# Web subnet inbound ports (Internet -> web)
variable "web_inbound_ports" {
  type    = list(number)
  default = [80, 443]
}

# DB ports allowed from workload -> db
variable "db_ports" {
  type    = list(number)
  default = [1433] # SQL Server by default; add 3306, 5432, etc.
}

# Mgmt inbound CIDRs (corp/VPN)
variable "mgmt_inbound_cidrs" {
  type    = list(string)
  default = []
}

# NAT gateway for private subnets (workload + db)
variable "enable_nat_gateway" {
  type    = bool
  default = true
}
