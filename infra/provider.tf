terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.41.0"
    }
  }
}

provider "azurerm" {
  features {}
  #   subscription_id = "enter-your-subscription-id-here"
}

terraform {
  backend "azurerm" {
    # resource_group_name  = "ritkargv"
    # storage_account_name = "ritkasav"
    # container_name       = "ritkascv"
    # key                  = "first.tfstate"
  }
}