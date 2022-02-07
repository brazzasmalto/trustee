data "azurerm_client_config" "current" {}

locals {
  tenant_id = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id

  # Returns 'true' if the word 'any' exists in the IP rules list.
  is_any_acl_present = try(contains(var.key_vault_network_acls.ip_rules, "any"), false)

  key_vault_network_acls = [
    local.is_any_acl_present || var.key_vault_network_acls == null || length(var.key_vault_network_acls.ip_rules) == 0 && length(var.key_vault_network_acls.virtual_network_subnet_ids) == 0 ? {
      bypass                     = "AzureServices",
      default_action             = "Allow",
      ip_rules                   = [],
      virtual_network_subnet_ids = []
    } : var.key_vault_network_acls
  ]
}
resource "azurerm_key_vault" "key_vault" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  tags                            = var.tags
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
#  soft_delete_retention_days      = var.soft_delete_retention_days

  timeouts {
    delete = "60m"
  }

  network_acls {
    bypass                     = var.bypass
    default_action             = var.default_action
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "purge",
      "setissuers",
      "update",
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]
  }

  lifecycle {
      ignore_changes = [
          tags
      ]
  }
}

resource "azurerm_key_vault_access_policy" "read_only" {
  for_each = toset(var.read_only_principals_object_ids)

  object_id    = each.value
  tenant_id    = local.tenant_id
  key_vault_id = azurerm_key_vault.key_vault.id

  key_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_key_vault_access_policy" "admin" {
  for_each = toset(var.admin_principals_object_ids)

  object_id    = each.value
  tenant_id    = local.tenant_id
  key_vault_id = azurerm_key_vault.key_vault.id

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update",
  ]
}

#resource "random_id" "id" {
#  byte_length = 8
#}
#
#resource "azurerm_monitor_diagnostic_setting" "settings" {
#  name                       = "${random_id.id.hex}_diagnostics_settings"
#  target_resource_id         = azurerm_key_vault.key_vault.id
#  log_analytics_workspace_id = var.log_analytics_workspace_id
#
#  log {
#    category = "AuditEvent"
#    enabled  = true
#
#    retention_policy {
#      enabled = true
#      days    = var.log_analytics_retention_days
#    }
#  }
#
#  log {
#    category = "AzurePolicyEvaluationDetails"
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