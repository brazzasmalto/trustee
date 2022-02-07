variable "name" {
  description = "Specifies the firewall name"
  type        = string
}

variable "sku_tier" {
  description = "Specifies the firewall sku tier"
  type        = string
  default     = "Standard"
}

variable "resource_group_name" {
  description = "Specifies the resource group name"
  type        = string
}

variable "location" {
  description = "Specifies the location where firewall will be deployed"
  type        = string
}

variable "threat_intel_mode" {
  description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny. Defaults to Alert."
  type        = string
  default     = "Alert"

  validation {
    condition = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "The threat intel mode is invalid."
  }
}

variable "zones" {
  description = "Specifies the availability zones of the Azure Firewall"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "pip_name" {
  description = "Specifies the firewall public IP name"
  type        = string
  default     = "azure-fw-ip"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 7
}

variable "public_ip_allocation_method" {
  description = "(Required) Specifies the allocation method for this IP address. Possible values are Static or Dynamic"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "(Required) Specifies the SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic"
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "(Optional) Specifies the tags of the firewall"
  type        = map(string)
  default     = {}
}