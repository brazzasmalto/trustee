output "id" {
  description = "The Resource ID of the Resource Group"
  value = azurerm_resource_group.resource_group.id
}

output "name" {
  description = "The Resource name of the Resource Group"
  value = azurerm_resource_group.resource_group.name
}