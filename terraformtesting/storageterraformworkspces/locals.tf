locals {
  # The active Terraform workspace is the environment
  env = terraform.workspace

  # Per-workspace configuration
  env_config = {
    dev = {
      location             = "australiaeast"
      resource_group_name  = "rg-storage-dev"
      storage_account_name = "ststoragedev01"
      tags = {
        environment = "dev"
        managed_by  = "terraform"
      }
    }

    uat = {
      location             = "australiaeast"
      resource_group_name  = "rg-storage-uat"
      storage_account_name = "ststorageuat01"
      tags = {
        environment = "uat"
        managed_by  = "terraform"
      }
    }

    prod = {
      location             = "australiaeast"
      resource_group_name  = "rg-storage-prod"
      storage_account_name = "ststorageprod01"
      tags = {
        environment = "prod"
        managed_by  = "terraform"
      }
    }
  }

  # Select config for the active workspace
  current = local.env_config[local.env]
}
