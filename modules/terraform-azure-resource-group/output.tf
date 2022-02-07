output "az_rg_id" {
  description = "The Respurce ID of the Resource Group"
  value = "${azurerm_resource_group.az_rg.id}"
}

output "az_rg_name" {
  description = "The Respurce name of the Resource Group"
  value = "${var.name}"
}