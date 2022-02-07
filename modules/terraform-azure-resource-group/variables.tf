variable "name" {
  description = "(Required) name of the resource group"
  default = "cloud"
}

variable "env" {
  description = "(Required) name of the resource group"
  default = "dev"
}

variable "location" {
  description = "(Required) location where this resource has to be created"
  default = "westeurope"
}

variable "team_tag" {
  description = "(Optional) tag a team"
  default = "DevOps"
}

variable "creator" {
  description = "(Optional) tag a creator"
  default =   "iankesh"
}
