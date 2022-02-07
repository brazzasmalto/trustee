variable "location" {
  description = "Specifies the location for the resource group and all the resources"
  type        = string
}

variable "name" {
  description = "Specifies the resource group name"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  type        = map(string)
  default     = {}
}

