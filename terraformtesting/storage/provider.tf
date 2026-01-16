provider "azurerm" {
  features {}

#  subscription_id = "0f1c21d3-1985-4b39-b41e-059f11f4d5ce"
#  tenant_id       = "7ad7e92b-f714-4f87-8b0c-297eefcad1b3"

  # IMPORTANT:
  # Do NOT set client_id/use_oidc/oidc_token here when using TFC dynamic creds.
}
