variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
  default     = "b87de7fe-844d-4fd7-aaa7-2754e58c687a"
}

variable "resource_group_owner" {
  description = "The owner of the resource group."
  type        = string
  default     = "andreas.hopfgartner@microsoft.com"
}

variable "resource_group_location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "system_node_pool_vm_size" {
  type        = string
  description = "The size of the Virtual Machine."
  default     = "standard_d2as_v6"
}

variable "system_node_pool_node_count" {
  type        = number
  description = "The initial quantity of nodes for the system node pool."
  default     = 1
}

variable "ray_node_pool_vm_size" {
  type        = string
  description = "The size of the Virtual Machine."
  default     = "standard_d4as_v6"
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
  default     = null
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}