
locals {
  # The active Terraform workspace is the environment
  env = terraform.workspace

  # Per-workspace configuration
  env_config = {
    azuredevops = {
      location             = "australiaeast"
      resource_group_name  = "rg-storage-dev"
      storage_account_name = "ststoragedev01"
      tags = {
        environment = "dev"
        managed_by  = "terraform"
      }
    }

  

  # Select config for the active workspace
  current = azuredevops
}
}
