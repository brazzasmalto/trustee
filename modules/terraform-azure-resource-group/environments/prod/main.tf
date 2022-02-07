provider "azurerm" {
  version = "=2.20.0"
  features {}
}

module "az_resource_group" {
  source   = "iankesh/resource-group/azure"
  env      = "ankesh-workspace-prod"
  location = "westeurope"
  team_tag = "DevOps"
  creator  = "ankesh"
}

output "az_rg_id" {
  value = module.az_resource_group.az_rg_id
}