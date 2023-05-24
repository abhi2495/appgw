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
}

resource "azurerm_subnet" "appgw" {
  name                 = var.APPGW_SUBNET_NAME
  resource_group_name  = var.RESOURCE_GROUP_NAME
  virtual_network_name = azurerm_virtual_network.mlstudio.name
  address_prefixes     = [var.APPGW_SUBNET_ADDRESS_PREFIX]
}

resource "azurerm_subnet" "aks" {
  name                 = var.AKS_SUBNET_NAME
  resource_group_name  = var.RESOURCE_GROUP_NAME
  virtual_network_name = azurerm_virtual_network.mlstudio.name
  address_prefixes     = [var.AKS_SUBNET_ADDRESS_PREFIX]
}

resource "azurerm_public_ip" "mlstudio" {
  name                = var.PUBLIC_IP_NAME
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.AZ_REGION
  allocation_method   = var.PUBLIC_IP_ALLOCATION_METHOD
  tags                = var.TAGS
}

locals {
  frontend_port_name             = "appgw-feport"
  frontend_ip_configuration_name = "appgw-feip"
  gateway_ip_configuration_name = "appgw-ip-config"

}

resource "azurerm_application_gateway" "mlstudio" {
  name                = var.APP_GATEWAY_NAME
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.AZ_REGION
  tags                = var.TAGS
  sku {
    name     = var.APP_GATEWAY_SKU_NAME
    tier     = var.APP_GATEWAY_SKU_TIER
    capacity = var.APP_GATEWAY_SKU_CAPACITY
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.mlstudio.id
  }
  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.appgw.id
  }
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
}