resource "random_string" "tf-name" {
  length = 8
  upper = false
  number = true
  lower = true
  special = false
}

resource "azurerm_container_registry" "acr" {
  name = "${lower(var.name)}tf${random_string.tf-name.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku  
  admin_enabled            = var.admin_enabled
  tags                     = var.tags

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.acr_identity.id
    ]
  }

  dynamic "georeplications" {
    for_each = var.georeplication_locations

    content {
      location = georeplications.value
      tags     = var.tags
    }
  }

  lifecycle {
      ignore_changes = [
          tags
      ]
  }
}

resource "azurerm_user_assigned_identity" "acr_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  name = "${var.name}Identity"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

#resource "random_id" "id" {
#  byte_length = 8
#}
#
#resource "azurerm_monitor_diagnostic_setting" "settings" {
#  name                       = "${random_id.id.hex}_diagnostics_settings"
#  target_resource_id         = azurerm_container_registry.acr.id
#  log_analytics_workspace_id = var.log_analytics_workspace_id
#
#  log {
#    category = "ContainerRegistryRepositoryEvents"
#    enabled  = true
#
#    retention_policy {
#      enabled = true
#      days    = var.log_analytics_retention_days
#    }
#  }
#
#  log {
#    category = "ContainerRegistryLoginEvents"
#    enabled  = true
#
#    retention_policy {
#      enabled = true
#      days    = var.log_analytics_retention_days
#    }
#  }
#
#  metric {
#    category = "AllMetrics"
#
#    retention_policy {
#      enabled = true
#      days    = var.log_analytics_retention_days
#    }
#  }
#}