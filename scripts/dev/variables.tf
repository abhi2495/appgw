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
