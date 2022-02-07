terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.83.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

locals {
  storage_account_prefix = "filezrspremium"
  route_table_name       = "routetable"
  route_name             = "routetabletofw"
  unique_id              = module.trustee_random_id.random_unique_id
}

data "azurerm_client_config" "current" {
}

module "trustee_resource_group" {
  source              = "../../modules/trustee_resource_group"
  name                = var.resource_group_name
  location            = var.location
}

module "trustee_random_password" {
  source = "../../modules/trustee_random_password"
  keepers = {
    time = timestamp()
  }
}

module "trustee_random_string" {
  source = "../../modules/trustee_random_string"
}

module "trustee_random_id" {
  source = "../../modules/trustee_random_id"
}

module "trustee_log_analytics_workspace" {
  source                           = "../../modules/trustee_log_analytics"
  name                             = var.log_analytics_workspace_name
  location                         = var.location
  resource_group_name              = module.trustee_resource_group.name
  solution_plan_map                = var.solution_plan_map
}

module "trustee_hub_network" {
  source                       = "../../modules/trustee_virtual_network"
  resource_group_name          = module.trustee_resource_group.name
  location                     = var.location
  vnet_name                    = var.hub_vnet_name
  address_space                = var.hub_address_space
  tags                         = var.tags
  log_analytics_workspace_id   = module.trustee_log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days

  subnets = [
    {
      name : "AzureFirewallSubnet"
      address_prefixes : var.hub_firewall_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    },
    {
      name : "AzureBastionSubnet"
      address_prefixes : var.hub_bastion_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    }
  ]
}

module "trustee_bastion_host" {
  source                       = "../../modules/trustee_bastion_host"
  name                         = var.bastion_host_name
  location                     = var.location
  resource_group_name          = module.trustee_resource_group.name
  subnet_id                    = module.trustee_hub_network.subnet_ids["AzureBastionSubnet"]
  log_analytics_workspace_id   = module.trustee_log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days
}

module "trustee_firewall" {
  source                       = "../../modules/trustee_network_firewall"
  name                         = var.firewall_name
  resource_group_name          = module.trustee_resource_group.name
  zones                        = var.firewall_zones
  threat_intel_mode            = var.firewall_threat_intel_mode
  location                     = var.location
  sku_tier                     = var.firewall_sku_tier
  pip_name                     = "${var.firewall_name}-public-ip"
  subnet_id                    = module.trustee_hub_network.subnet_ids["AzureFirewallSubnet"]
  log_analytics_workspace_id   = module.trustee_log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days
}

module "trustee_aks_network" {
  source                       = "../../modules/trustee_virtual_network"
  resource_group_name          = module.trustee_resource_group.name
  location                     = var.location
  vnet_name                    = var.spoke_aks_vnet_name
  address_space                = var.aks_vnet_address_space
  log_analytics_workspace_id   = module.trustee_log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days

  subnets = [
    {
      name : var.default_node_pool_subnet_name
      address_prefixes : var.default_node_pool_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    },
    {
      name : var.additional_node_pool_subnet_name
      address_prefixes : var.additional_node_pool_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    },
    {
      name : var.vm_subnet_name
      address_prefixes : var.vm_subnet_address_prefix
      enforce_private_link_endpoint_network_policies : true
      enforce_private_link_service_network_policies : false
    }
  ]
}

module "trustee_routetable" {
  source               = "../../modules/trustee_route_table"
  resource_group_name  = module.trustee_resource_group.name
  location             = var.location
  route_table_name     = local.route_table_name
  route_name           = local.route_name
  firewall_private_ip  = module.trustee_firewall.private_ip_address
  subnets_to_associate = {
    (var.default_node_pool_subnet_name) = {
      subscription_id      = data.azurerm_client_config.current.subscription_id
      resource_group_name  = module.trustee_resource_group.name
      virtual_network_name = module.trustee_aks_network.name
    }
    (var.additional_node_pool_subnet_name) = {
      subscription_id      = data.azurerm_client_config.current.subscription_id
      resource_group_name  = module.trustee_resource_group.name
      virtual_network_name = module.trustee_aks_network.name
    }
  }
}

module "trustee_vnet_peering" {
  source              = "../../modules/trustee_virtual_network_peering"
  vnet_1_name         = var.hub_vnet_name
  vnet_1_id           = module.trustee_hub_network.vnet_id
  vnet_1_rg           = module.trustee_resource_group.name
  vnet_2_name         = var.spoke_aks_vnet_name
  vnet_2_id           = module.trustee_aks_network.vnet_id
  vnet_2_rg           = module.trustee_resource_group.name
  peering_name_1_to_2 = "${var.hub_vnet_name}To${var.spoke_aks_vnet_name}"
  peering_name_2_to_1 = "${var.spoke_aks_vnet_name}To${var.hub_vnet_name}"
}

module "trustee_container_registry" {
  source                       = "../../modules/trustee_container_registry"
  name                         = var.acr_name
  resource_group_name          = module.trustee_resource_group.name
  location                     = var.location
  sku                          = var.acr_sku
  admin_enabled                = var.acr_admin_enabled
  georeplication_locations     = var.acr_georeplication_locations
  log_analytics_workspace_id   = module.trustee_log_analytics_workspace.id
  log_analytics_retention_days = var.log_analytics_retention_days
}

module "trustee_aks_cluster" {
  source                                   = "../../modules/trustee_aks_cluster"
  name                                     = var.aks_cluster_name
  location                                 = var.location
  resource_group_name                      = module.trustee_resource_group.name
  resource_group_id                        = module.trustee_resource_group.id
  kubernetes_version                       = var.kubernetes_version
  dns_prefix                               = lower(var.aks_cluster_name)
  private_cluster_enabled                  = true
  automatic_channel_upgrade                = var.automatic_channel_upgrade
  sku_tier                                 = var.sku_tier
  default_node_pool_name                   = var.default_node_pool_name
  default_node_pool_vm_size                = var.default_node_pool_vm_size
  vnet_subnet_id                           = module.trustee_aks_network.subnet_ids[var.default_node_pool_subnet_name]
  default_node_pool_availability_zones     = var.default_node_pool_availability_zones
  default_node_pool_node_labels            = var.default_node_pool_node_labels
  default_node_pool_node_taints            = var.default_node_pool_node_taints
  default_node_pool_enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
  default_node_pool_enable_host_encryption = var.default_node_pool_enable_host_encryption
  default_node_pool_enable_node_public_ip  = var.default_node_pool_enable_node_public_ip
  default_node_pool_max_pods               = var.default_node_pool_max_pods
  default_node_pool_max_count              = var.default_node_pool_max_count
  default_node_pool_min_count              = var.default_node_pool_min_count
  default_node_pool_node_count             = var.default_node_pool_node_count
  default_node_pool_os_disk_type           = var.default_node_pool_os_disk_type
  network_docker_bridge_cidr               = var.network_docker_bridge_cidr
  network_dns_service_ip                   = var.network_dns_service_ip
  network_plugin                           = var.network_plugin
  outbound_type                            = "userDefinedRouting"
  network_service_cidr                     = var.network_service_cidr
  log_analytics_workspace_id               = module.trustee_log_analytics_workspace.id
  role_based_access_control_enabled        = var.role_based_access_control_enabled
  tenant_id                                = data.azurerm_client_config.current.tenant_id
  admin_group_object_ids                   = var.admin_group_object_ids
  azure_rbac_enabled                       = var.azure_rbac_enabled
  admin_username                           = var.admin_username
  ssh_public_key                           = var.ssh_public_key
  depends_on                               = [module.trustee_routetable]

  tags                                     = var.tags
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                                    = module.trustee_resource_group.id
  role_definition_name                     = "Network Contributor"
  principal_id                             = module.trustee_aks_cluster.aks_identity_principal_id
  skip_service_principal_aad_check         = true
}

resource "azurerm_role_assignment" "acr_pull" {
  role_definition_name                     = "AcrPull"
  scope                                    = module.trustee_container_registry.id
  principal_id                             = module.trustee_aks_cluster.kubelet_identity_object_id
  skip_service_principal_aad_check         = true
}

module "trustee_storage_account" {
  source                      = "../../modules/trustee_storage_account"
  name                        = "${local.storage_account_prefix}${module.trustee_random_string.resource_code}"
  location                    = var.location
  resource_group_name         = module.trustee_resource_group.name
  account_kind                = var.storage_account_kind
  account_tier                = var.storage_account_tier
  replication_type            = var.storage_account_replication_type
}

module "trustee_acr_private_dns_zone" {
  source                       = "../../modules/trustee_private_dns_zone"
  name                         = "privatelink.azurecr.io"
  resource_group_name          = module.trustee_resource_group.name
  virtual_networks_to_link     = {
    (module.trustee_hub_network.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = module.trustee_resource_group.name
    }
    (module.trustee_aks_network.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = module.trustee_resource_group.name
    }
  }
}

module "trustee_acr_private_endpoint" {
  source                         = "../../modules/trustee_private_endpoint"
  name                           = "${module.trustee_container_registry.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = module.trustee_resource_group.name
  subnet_id                      = module.trustee_aks_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.trustee_container_registry.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.trustee_acr_private_dns_zone.id]
}

module "trustee_blob_private_dns_zone" {
  source                       = "../../modules/trustee_private_dns_zone"
  name                         = "privatelink.blob.core.windows.net"
  resource_group_name          = module.trustee_resource_group.name
  virtual_networks_to_link     = {
    (module.trustee_hub_network.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = module.trustee_resource_group.name
    }
    (module.trustee_aks_network.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = module.trustee_resource_group.name
    }
  }
}

module "trustee_blob_private_endpoint" {
  source                         = "../../modules/trustee_private_endpoint"
  name                           = "${title(module.trustee_storage_account.name)}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = module.trustee_resource_group.name
  subnet_id                      = module.trustee_aks_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.trustee_storage_account.id
  is_manual_connection           = false
  subresource_name               = "blob"
  private_dns_zone_group_name    = "BlobPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.trustee_blob_private_dns_zone.id]
}

module "trustee_key_vault" {
  source                          = "../../modules/trustee_key_vault"
  name                            = var.key_vault_name
  location                        = var.location
  resource_group_name             = module.trustee_resource_group.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_name
  tags                            = var.tags
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  bypass                          = var.key_vault_bypass
  default_action                  = var.key_vault_default_action
  log_analytics_workspace_id      = module.trustee_log_analytics_workspace.id
  log_analytics_retention_days    = var.log_analytics_retention_days
}

module "trustee_key_vault_private_dns_zone" {
  source                       = "../../modules/trustee_private_dns_zone"
  name                         = "privatelink.vaultcore.azure.net"
  resource_group_name          = module.trustee_resource_group.name
  virtual_networks_to_link     = {
    (module.trustee_hub_network.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = module.trustee_resource_group.name
    }
    (module.trustee_aks_network.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = module.trustee_resource_group.name
    }
  }
}

module "trustee_key_vault_private_endpoint" {
  source                         = "../../modules/trustee_private_endpoint"
  name                           = "${title(module.trustee_key_vault.name)}-private-endpoint"
  location                       = var.location
  resource_group_name            = module.trustee_resource_group.name
  subnet_id                      = module.trustee_aks_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.trustee_key_vault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.trustee_key_vault_private_dns_zone.id]
}

