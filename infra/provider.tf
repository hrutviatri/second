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
    subscription_id = "95a90f4b-7e15-47ba-95ab-0d52bac078e4"
}

terraform {
  backend "azurerm" {
    # resource_group_name  = "ritkargv"
    # storage_account_name = "ritkasav"
    # container_name       = "ritkascv"
    # key                  = "first.tfstate"
  }
}