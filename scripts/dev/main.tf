terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

  backend "azurerm" {
    key = "mlstudio.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_user_assigned_identity" "mlstudio" {
  location            = var.AZ_REGION
  name                = var.MANAGED_IDENTITY_NAME
  resource_group_name = var.RESOURCE_GROUP_NAME
  tags                = var.TAGS
}

resource "azurerm_virtual_network" "mlstudio" {
  name                = var.VNET_NAME
  location            = var.AZ_REGION
  resource_group_name = var.RESOURCE_GROUP_NAME
  address_space       = split(",", var.TF_VAR_VNET_ADDRESS)
  tags                = var.TAGS
}