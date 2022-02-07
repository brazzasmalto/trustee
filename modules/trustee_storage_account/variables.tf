variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the storage account"
  type        = string
}

variable "name" {
  description = "(Required) Specifies the name of the storage account"
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location of the storage account"
  type        = string
}

variable "account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  type        = string
  default     = "StorageV2"

   validation {
    condition = contains(["Storage", "StorageV2"], var.account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}

variable "account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  type        = string
  default     = "Standard"

   validation {
    condition = contains(["Standard", "Premium"], var.account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}

variable "replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  type        = string
  default     = "ZRS"

  validation {
    condition = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}

variable "is_hns_enabled" {
  description = "(Optional) Specifies the replication type of the storage account"
  type        = bool
  default     = false
  }

variable "default_action" {
  description = "Allow or disallow public access to all blobs or containers in the storage accounts. The default interpretation is true for this property."
  type        = string
  default     = "Allow"
  }

variable "ip_rules" {
  description = "Specifies IP rules for the storage account"
  type        = list(string)
  default     = []
}

variable "virtual_network_subnet_ids" {
  description = "Specifies a list of resource ids for subnets"
  type        = list(string)
  default     = []
}

variable "kind" {
  description = "(Optional) Specifies the kind of the storage account"
  type        = string
  default     = ""
}

variable "tags" {
  description = "(Optional) Specifies the tags of the storage account"
  type        = map(string)
  default     = {}
}