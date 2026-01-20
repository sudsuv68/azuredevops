terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
   
}
subscription_id = "0f1c21d3-1985-4b39-b41e-059f11f4d5ce"
  #tenant_id       = var.tenant_id
}

  

