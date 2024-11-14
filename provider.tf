terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.77.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
   subscription_id = "33b7b305-44f2-4223-881d-46a8ebaa2e69"
skip_provider_registration = true
#resource_provider_registrations = "none"
 features {}
}
