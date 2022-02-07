provider "azurerm" {
  version = "=2.20.0"
  features {}
}

module "az_resource_group" {
  source   = "iankesh/resource-group/azure"
  env      = "ankesh-workspace"
  location = "westeurope"
  team_tag = "DevOps"
  creator  = "ankesh"
}

output "azure_resource_group_id" {
  value = module.az_resource_group.az_rg_id
}

output "azure_resource_group_name" {
  value = module.az_resource_group.az_rg_name
}