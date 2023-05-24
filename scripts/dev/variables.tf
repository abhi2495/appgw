variable "RESOURCE_GROUP_NAME" {
  description = "Resource Group Name for Infra deployment"
}

variable "MANAGED_IDENTITY_NAME" {
  description = "Name of the managed identity"
}

variable "AZ_REGION" {
  description = "Location of the resource"
}

variable "TAGS" {
  type        = map(string)
  description = "Tags to be included on the resources"
}

variable "VNET_NAME" {
  description = "Name of the virtual network"
}

variable "VNET_ADDRESS" {
  description = "The address space that is used the virtual network. We can supply more than one address space using comma separated values."
}

variable "APPGW_SUBNET_NAME" {
  description = "Name of the subnet to be used for Application Gateway"
}

variable "APPGW_SUBNET_ADDRESS_PREFIX" {
  description = "Address prefix of the subnet to be used for Application Gateway"
}

variable "AKS_SUBNET_NAME" {
  description = "Name of the subnet to be used for AKS Cluster"
}

variable "AKS_SUBNET_ADDRESS_PREFIX" {
  description = "Address prefix of the subnet to be used for AKS Cluster"
}

variable "PUBLIC_IP_NAME" {
  description = "Name of the Public IP."
}

variable "PUBLIC_IP_ALLOCATION_METHOD" {
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic."
}

variable "APP_GATEWAY_NAME" {
  description = "The name of the Application Gateway."
}

variable "APP_GATEWAY_SKU_NAME" {
  description = "The Name of the SKU to use for this Application Gateway. Possible values are Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2."
}

variable "APP_GATEWAY_SKU_TIER" {
  description = "The Tier of the SKU to use for this Application Gateway. Possible values are Standard, Standard_v2, WAF and WAF_v2"
}

variable "APP_GATEWAY_SKU_CAPACITY" {
  description = "The Capacity of the SKU to use for this Application Gateway. When using a V1 SKU this value must be between 1 and 32, and 1 to 125 for a V2 SKU. This property is optional if autoscale_configuration is set."
}