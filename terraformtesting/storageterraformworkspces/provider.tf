terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.57.0"
    }
  }

  cloud {
    organization = "sidazureorg"

    workspaces {
      name = "azuredevops" # Blast radius restriction
    }
  }
}