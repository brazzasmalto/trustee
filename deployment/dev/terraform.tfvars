###
#
###
location                                                    = "westeurope"
resource_group_name                                         = "rg-trustee-application-001"
sku_tier                                                    = "Paid"

###
# Hub Vnet
###
hub_vnet_name                                               = "hub"
hub_address_space                                           = ["10.1.0.0/16"]
hub_firewall_subnet_address_prefix                          = ["10.1.0.0/24"]
hub_bastion_subnet_address_prefix                           = ["10.1.1.0/24"]
bastion_host_name                                           = "trustee-bastion-module"

###
# Log analytics workspace
###
log_analytics_workspace_name                                = "TrusteeAksWorkspace21"
log_analytics_retention_days                                = 30
solution_plan_map = {
  ContainerInsights= {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

###
# Spoke AKS Vnet
###
spoke_aks_vnet_name                                         = "aks"
aks_vnet_address_space                                      = ["10.0.0.0/16"]
vm_subnet_name                                              = "vms"
vm_subnet_address_prefix                                    = ["10.0.8.0/21"]
aks_cluster_name                                            = "trustee-aks"
role_based_access_control_enabled                           = true
automatic_channel_upgrade                                   = "stable"
admin_group_object_ids                                      = ["6e5de8c1-5a4b-409b-994f-0706e4403b77", "78761057-c58c-44b7-aaa7-ce1639c6c4f5"]
azure_rbac_enabled                                          = true
kubernetes_version                                          = "1.22.4"
default_node_pool_vm_size                                   = "Standard_F8s_v2"
default_node_pool_availability_zones                        = ["1", "2", "3"]
network_docker_bridge_cidr                                  = "172.17.0.1/16"
network_dns_service_ip                                      = "10.2.0.10"
network_service_cidr                                        = "10.2.0.0/24"
network_plugin                                              = "azure"
additional_node_pool_subnet_address_prefix                  = ["10.0.16.0/20"]
additional_node_pool_name                                   = "user"
default_node_pool_name                                      = "system"
default_node_pool_subnet_name                               = "SystemSubnet"
default_node_pool_subnet_address_prefix                     = ["10.0.0.0/21"]
default_node_pool_enable_auto_scaling                       = true
default_node_pool_enable_host_encryption                    = false
default_node_pool_enable_node_public_ip                     = false
default_node_pool_max_pods                                  = 50
default_node_pool_node_labels = {
  "nodepool-type"    = "system"
  "nodepoolos"       = "linux"
  "app"              = "system-apps"
}

default_node_pool_node_taints                               = []
default_node_pool_os_disk_type                              = "Ephemeral"
default_node_pool_max_count                                 = 10
default_node_pool_min_count                                 = 3
default_node_pool_node_count                                = 3
additional_node_pool_subnet_name                            = "UserSubnet"
additional_node_pool_vm_size                                = "Standard_F8s_v2"
additional_node_pool_availability_zones                     = ["1", "2", "3"]
additional_node_pool_enable_auto_scaling                    = true
additional_node_pool_enable_host_encryption                 = false
additional_node_pool_enable_node_public_ip                  = false
additional_node_pool_max_pods                               = 50
additional_node_pool_mode                                   = "User"
additional_node_pool_node_labels                            = {}
additional_node_pool_node_taints                            = ["CriticalAddonsOnly=true:NoSchedule"]
additional_node_pool_os_disk_type                           = "Ephemeral"
additional_node_pool_os_type                                = "Linux"
additional_node_pool_priority                               = "Regular"
additional_node_pool_max_count                              = 10
additional_node_pool_min_count                              = 3
additional_node_pool_node_count                             = 3
domain_name_label                                           = "Trusteetestvm"

###
# Firewall Networking
###
firewall_name                                               = "TrusteeFirewall"
firewall_sku_tier                                           = "Standard"
firewall_threat_intel_mode                                  = "Alert"
firewall_zones                                              = ["1", "2", "3"]

###
# VM provision
###
vm_name                                                     = "TestVm"
vm_public_ip                                                = false
vm_size                                                     = "Standard_F8s_v2"
vm_os_disk_storage_account_type                             = "StandardSSD_LRS"
vm_os_disk_image = {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
  version   = "latest"
}

###
# Storage account
###
storage_account_kind                                        = "StorageV2"
storage_account_tier                                        = "Premium"
storage_account_replication_type                            = "LRS"


###
# ACR
###
acr_name                                                    = "trustee"
acr_sku                                                     = "Premium"
acr_admin_enabled                                           = true
acr_georeplication_locations                                = []


###
# Key vault
###
key_vault_name                                              = "trustee-application-001"
key_vault_sku_name                                          = "standard"
key_vault_enabled_for_deployment                            = true
key_vault_enabled_for_disk_encryption                       = true
key_vault_enabled_for_template_deployment                   = true
key_vault_enable_rbac_authorization                         = true
key_vault_purge_protection_enabled                          = true
key_vault_soft_delete_retention_days                        = 30
key_vault_bypass                                            = "AzureServices"
key_vault_default_action                                    = "Allow"

###
# Other...
###
admin_username                                              = "azadmin"
ssh_public_key                                              = "~/.ssh/id_rsa.pub"
container_name                                              = "scripts"
script_name                                                 = "configure-jumpbox-vm.sh"
tags = {
  ProjectName  = "trustee-transformation"
  Env          = "dev"
  Owner        = "FT Trustee"
}
