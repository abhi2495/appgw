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
  address_space       = split(",", var.VNET_ADDRESS)
  tags                = var.TAGS

  dynamic "subnet" {
    for_each = var.SUBNETS
    content {
      name            = subnet.value["name"]
      address_prefix  = setting.value["address_prefix"]
    }
  }
}

# resource "azurerm_public_ip" "example" {
#   name                = "acceptanceTestPublicIp1"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   allocation_method   = "Static"
#   tags                = var.TAGS
# }