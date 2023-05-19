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


resource "azurerm_user_assigned_identity" "mlstudio" {
  location            = var.AZ_REGION
  name                = var.MANAGED_IDENTITY_NAME
  resource_group_name = var.RESOURCE_GROUP_NAME
  tags                = var.TAGS
}

