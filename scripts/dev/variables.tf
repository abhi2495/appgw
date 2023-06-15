variable "RESOURCE_GROUP_NAME" {
  description = "Resource Group Name for Infra deployment"
}

variable "AZ_SPN_DISPLAY_NAME" {
  description = "Display name of the service principal"
}

variable "AZ_SPN_CLIENT_ID" {
  description = "Client id of the service principal"
}

variable "AZ_SPN_CLIENT_SECRET" {
  description = "Client Secret of the service principal"
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

variable "PUBLIC_IP_SKU" {
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic"
  default     = "Basic"
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

variable "APP_GATEWAY_WAF_ENABLED" {
  description = "Is the Web Application Firewall enabled for App Gateway ?"
  type        = bool
}

variable "APP_GATEWAY_WAF_FIREWALL_MODE" {
  description = "The Web Application Firewall Mode. Possible values are Detection and Prevention."
}

variable "APP_GATEWAY_WAF_RULE_SET_TYPE" {
  description = "The Type of the Rule Set used for this Web Application Firewall. Possible values are OWASP and Microsoft_BotManagerRuleSet."
}

variable "APP_GATEWAY_WAF_RULE_SET_VERSION" {
  description = "The Version of the Rule Set used for this Web Application Firewall. Possible values are 0.1, 1.0, 2.2.9, 3.0, 3.1 and 3.2."
}


variable "AKS_NAME" {
  description = "The name of the Managed Kubernetes Cluster to create."
}

variable "AKS_NETWORK_PLUGIN" {
  description = "Network plugin to use for networking. Currently supported values are azure, kubenet and none."
}

/* variable "AKS_SERVICE_CIDR" {
  description = "The Network Range used by the Kubernetes service."
}

variable "AKS_DNS_SERVICE_IP" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)."
} */

variable "AKS_DEFAULT_NODE_POOL_COUNT" {
  description = "The initial number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
}

variable "AKS_DEFAULT_NODE_POOL_VM_SIZE" {
  description = "The size of the Virtual Machine, such as Standard_DS2_v2"
}

variable "AKS_DNS_PREFIX" {
  description = "DNS prefix specified when creating the managed cluster. Possible values must begin and end with a letter or number, contain only letters, numbers, and hyphens and be between 1 and 54 characters in length."
}

variable "AKS_DEFAULT_NODE_POOL_OS" {
  description = "Specifies the OS SKU used by the agent pool. Possible values include: Ubuntu, CBLMariner, Mariner, Windows2019, Windows2022. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows. And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated."
}

variable "AKS_DEFAULT_NODE_POOL_ENABLE_AUTOSCALING" {
  type        = bool
  description = "Should the Kubernetes Auto Scaler be enabled for this Node Pool?"
}

variable "AKS_DEFAULT_NODE_POOL_TYPE" {
  description = "The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets"
}

variable "AKS_DEFAULT_NODE_POOL_MAX_NODE_COUNT" {
  description = "The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
  default     = 1
}

variable "AKS_DEFAULT_NODE_POOL_MIN_NODE_COUNT" {
  description = "The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
  default     = 1
}

variable "AKS_DEFAULT_NODE_POOL_OS_DISK_SIZE" {
  description = "The size of the OS Disk in GB which should be used for each agent in the Node Pool."
}

variable "AKS_DEFAULT_NODE_POOL_MAX_PODS" {
  description = "The maximum number of pods that can run on each agent."
}

variable "AKS_DEFAULT_NODE_POOL_ENABLE_NODE_PUBLIC_IP" {
  type        = bool
  description = "Should nodes in this Node Pool have a Public IP Address?"
  default     = false
}

variable "STORAGE_ACCOUNT_NAME" {
  description = "Specifies the name of the storage account. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group."
}

variable "STORAGE_ACCOUNT_TIER" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid."
}

variable "STORAGE_ACCOUNT_REPLICATION_TYPE" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
}

variable "KEYVAULT_NAME" {
  description = "Specifies the name of the Key Vault. Changing this forces a new resource to be created. The name must be globally unique. If the vault is in a recoverable state then the vault will need to be purged before reusing the name."
}

variable "ACR_NAME" {
  description = "Specifies the name of the Container Registry. Only Alphanumeric characters allowed. Changing this forces a new resource to be created."
}


variable "ACR_SKU" {
  description = "The SKU name of the container registry. Possible values are Basic, Standard and Premium"
}

variable "STORAGE_ACCOUNT_ALLOW_NESTED_ITEMS_TO_BE_PUBLIC" {
  type        = bool
  description = "Allow or disallow nested items within this Account to opt into being public."
  default     = false
}
