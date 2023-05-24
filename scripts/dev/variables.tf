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

variable "SUBNETS" {
  description = "The subnets to be associated with the virtual network"
  default = []
}