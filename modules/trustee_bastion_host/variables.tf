variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the bastion host"
  type        = string
}

variable "name" {
  description = "(Required) Specifies the name of the bastion host"
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location of the bastion host"
  type        = string
}

variable "subnet_id" {
  description = "(Required) Specifies subnet id of the bastion host"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "(Required) Specifies the log analytics workspace id"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "(Required) Specifies the number of days of the retention policy"
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

variable "domain_name_label" {
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system"
  type        = bool
  default     = null
}

variable "tags" {
  description = "(Optional) Specifies the tags of the bastion"
  type        = map(string)
  default     = {}
}