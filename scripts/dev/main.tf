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

data "azurerm_resource_group" "mlstudio" {
  name = var.RESOURCE_GROUP_NAME
}

data "azuread_service_principal" "mlstudio" {
  display_name = var.AZ_SPN_DISPLAY_NAME
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
  depends_on = [
    azurerm_virtual_network.mlstudio
  ]
  name                 = var.APPGW_SUBNET_NAME
  resource_group_name  = var.RESOURCE_GROUP_NAME
  virtual_network_name = azurerm_virtual_network.mlstudio.name
  address_prefixes     = [var.APPGW_SUBNET_ADDRESS_PREFIX]
}

resource "azurerm_subnet" "aks" {
  depends_on = [
    azurerm_virtual_network.mlstudio
  ]
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
  sku                 = var.PUBLIC_IP_SKU
  tags                = var.TAGS
}

locals {
  frontend_port_name             = "appgw-feport"
  frontend_ip_configuration_name = "appgw-feip"
  gateway_ip_configuration_name  = "appgw-ip-config"
  backend_address_pool_name      = "appgw-defaultbackendaddresspool"
  http_setting_name              = "appgw-defaulthttpsetting"
  health_probe_name              = "appgw-defaultprobe-http"
  http_listener_name             = "appgw-default-httplistner"
  request_routing_rule_name      = "appgw-rqrt"
}

resource "azurerm_application_gateway" "mlstudio" {
  depends_on = [
    azurerm_public_ip.mlstudio,
    azurerm_subnet.appgw
  ]
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
  frontend_port {
    name = "httpsPort"
    port = 443
  }
  backend_address_pool {
    name = local.backend_address_pool_name
  }
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
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
  dynamic "waf_configuration" {

    for_each = var.APP_GATEWAY_WAF_ENABLED == true ? toset([1]) : toset([])

    content {
      enabled          = var.APP_GATEWAY_WAF_ENABLED
      firewall_mode    = var.APP_GATEWAY_WAF_FIREWALL_MODE
      rule_set_type    = var.APP_GATEWAY_WAF_RULE_SET_TYPE
      rule_set_version = var.APP_GATEWAY_WAF_RULE_SET_VERSION
    }
  }
  lifecycle {
    ignore_changes = [
      # ignore changes to all these configurations as these seem to change after creating ingress controller in AKS
      request_routing_rule, probe, http_listener, backend_http_settings, backend_address_pool, tags
    ]
  }
}

resource "azurerm_role_assignment" "ra1" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.mlstudio.object_id
  depends_on           = [azurerm_virtual_network.mlstudio]
}

resource "azurerm_role_assignment" "ra2" {
  scope                = azurerm_user_assigned_identity.mlstudio.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azuread_service_principal.mlstudio.object_id
  depends_on           = [azurerm_user_assigned_identity.mlstudio]
}

resource "azurerm_role_assignment" "ra3" {
  scope                = azurerm_application_gateway.mlstudio.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.mlstudio.principal_id
  depends_on = [
    azurerm_user_assigned_identity.mlstudio,
    azurerm_application_gateway.mlstudio,
  ]
}

resource "azurerm_role_assignment" "ra4" {
  scope                = data.azurerm_resource_group.mlstudio.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.mlstudio.principal_id
  depends_on = [
    azurerm_user_assigned_identity.mlstudio,
    azurerm_application_gateway.mlstudio,
  ]
}

resource "azurerm_kubernetes_cluster" "mlstudio" {
  depends_on = [
    azurerm_application_gateway.mlstudio,
    azurerm_subnet.aks,
    azurerm_user_assigned_identity.mlstudio
  ]
  name                = var.AKS_NAME
  location            = var.AZ_REGION
  resource_group_name = var.RESOURCE_GROUP_NAME
  tags                = var.TAGS
  dns_prefix          = var.AKS_DNS_PREFIX

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.mlstudio.id
  }

  network_profile {
    network_plugin = var.AKS_NETWORK_PLUGIN
    /* service_cidr   = var.AKS_SERVICE_CIDR
    dns_service_ip = var.AKS_DNS_SERVICE_IP */
  }
  default_node_pool {
    name                  = "default"
    node_count            = var.AKS_DEFAULT_NODE_POOL_COUNT
    vm_size               = var.AKS_DEFAULT_NODE_POOL_VM_SIZE
    vnet_subnet_id        = azurerm_subnet.aks.id
    os_sku                = var.AKS_DEFAULT_NODE_POOL_OS
    os_disk_size_gb       = var.AKS_DEFAULT_NODE_POOL_OS_DISK_SIZE
    enable_auto_scaling   = var.AKS_DEFAULT_NODE_POOL_ENABLE_AUTOSCALING
    type                  = var.AKS_DEFAULT_NODE_POOL_TYPE
    max_count             = var.AKS_DEFAULT_NODE_POOL_ENABLE_AUTOSCALING == true ? var.AKS_DEFAULT_NODE_POOL_MAX_NODE_COUNT : null
    min_count             = var.AKS_DEFAULT_NODE_POOL_ENABLE_AUTOSCALING == true ? var.AKS_DEFAULT_NODE_POOL_MIN_NODE_COUNT : null
    max_pods              = var.AKS_DEFAULT_NODE_POOL_MAX_PODS
    enable_node_public_ip = var.AKS_DEFAULT_NODE_POOL_ENABLE_NODE_PUBLIC_IP
  }

  service_principal {
    client_id     = var.AZ_SPN_CLIENT_ID
    client_secret = var.AZ_SPN_CLIENT_SECRET
  }
}

resource "azurerm_storage_account" "mlstudio" {
  name                     = var.STORAGE_ACCOUNT_NAME
  resource_group_name      = var.RESOURCE_GROUP_NAME
  location                 = var.AZ_REGION
  account_tier             = var.STORAGE_ACCOUNT_TIER
  account_replication_type = var.STORAGE_ACCOUNT_REPLICATION_TYPE
  tags                     = var.TAGS
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "mlstudio" {
  name                        = var.KEYVAULT_NAME
  location                    = var.AZ_REGION
  resource_group_name         = var.RESOURCE_GROUP_NAME
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = var.TAGS
}

resource "azurerm_container_registry" "mlstudio" {
  name                = var.ACR_NAME
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.AZ_REGION
  sku                 = var.ACR_SKU
  tags                = var.TAGS
}
