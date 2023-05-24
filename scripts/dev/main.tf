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
  frontend_port_name              = "appgw-feport"
  frontend_ip_configuration_name  = "appgw-feip"
  gateway_ip_configuration_name   = "appgw-ip-config"
  backend_address_pool_name       = "appgw-defaultbackendaddresspool"
  http_setting_name               = "appgw-defaulthttpsetting"
  health_probe_name               = "appgw-defaultprobe-http"
  http_listener_name              = "appgw-default-httplistner"
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
  backend_address_pool {
    name = local.backend_address_pool_name
  }
  probe {
    name = local.health_probe_name
    interval = 30
    protocol = "Http"
    path = "/"
    timeout = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
  }
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = local.health_probe_name
    connection_draining {
      enabled = false
    }
  }
   http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}