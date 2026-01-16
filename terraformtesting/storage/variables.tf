variable "location" {
  type    = string
  default = "australiaeast"
}

variable "resource_group_name" {
  type = string
}

variable "storage_account_name" {
  type = string
  # Azure storage account naming rules:
  # - 3-24 chars
  # - lowercase letters and numbers only
}

variable "tags" {
  type    = map(string)
  default = {}
}
