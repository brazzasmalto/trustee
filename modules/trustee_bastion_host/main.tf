resource "azurerm_public_ip" "pip" {
  name                = lower("${var.name}-${var.resource_group_name}-public-ip")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku

  lifecycle {
      ignore_changes = [
          tags
      ]
  }
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  lifecycle {
      ignore_changes = [
          tags
      ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "trustee-diagnostics_settings-1"
  target_resource_id         = azurerm_bastion_host.bastion_host.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "BastionAuditLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }
}
#resource "random_id" "id" {
#  byte_length = 8
#}
#
#resource "azurerm_monitor_diagnostic_setting" "pip_settings" {
#  name                       = "${random_id.id.hex}_diagnostics_settings"
#  target_resource_id         = azurerm_public_ip.pip.id
#  log_analytics_workspace_id = var.log_analytics_workspace_id
#
#  log {
#    category = "DDoSProtectionNotifications"
#    enabled  = true
#
#    retention_policy {
#      enabled = true
#      days    = var.log_analytics_retention_days
#    }
#  }
#
#  log {
#    category = "DDoSMitigationFlowLogs"
#    enabled  = true
#
#    retention_policy {
#      enabled = true
#      days    = var.log_analytics_retention_days
#    }
#  }
#
#  log {
#    category = "DDoSMitigationReports"
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