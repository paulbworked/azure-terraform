locals {
  mandatory_tags = {
    source  = "terraform"
    company = "pab"
  }
  applied_tags = merge(var.resource_tags, local.mandatory_tags)
}

# Create resource group
resource "azurerm_resource_group" "aks-rgname" {
  name     = "rg-${var.bus_stack}-${var.env_stack}-${var.loc_code}-aks"
  location = var.region

  tags = local.applied_tags
}

# Creates managed ID
resource "azurerm_user_assigned_identity" "mi-aks" {
  name                = "mi-${var.bus_stack}-${var.env_stack}-${var.loc_code}"
  resource_group_name = azurerm_resource_group.aks-rgname.name
  location            = var.region

  depends_on = [
    azurerm_resource_group.aks-rgname,
  ]

  tags = local.applied_tags
}

resource "azurerm_role_assignment" "mi-aks-dns" {
  scope                = var.dns_scope
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-aks.principal_id

  depends_on = [
    azurerm_user_assigned_identity.mi-aks,
  ]
}

resource "azurerm_role_assignment" "mi-aks-net" {
  scope                = var.vnet_scope
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-aks.principal_id

  depends_on = [
    azurerm_user_assigned_identity.mi-aks,
  ]

}

resource "azurerm_role_assignment" "mi-kube_id-acrpull" {
  scope                = var.acr_scope
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                                = "aks-${var.bus_stack}-${var.env_stack}-${var.loc_code}"
  location                            = var.region
  resource_group_name                 = azurerm_resource_group.aks-rgname.name
  sku_tier                            = var.sku_tier
  dns_prefix                          = "aks-${var.bus_stack}-${var.env_stack}-${var.loc_code}"
  node_resource_group                 = "rg-${var.bus_stack}-${var.env_stack}-${var.loc_code}-aks-node"
  private_cluster_enabled             = var.pri_cluster_enabled
  private_dns_zone_id                 = var.pri_dns_zone_id
  private_cluster_public_fqdn_enabled = var.pub_fqdn_enabled
  http_application_routing_enabled    = var.http_app_route_enabled
  role_based_access_control_enabled   = var.rbac_enabled
  local_account_disabled              = var.local_acc_disabled
  kubernetes_version                  = var.kubes_version

  azure_active_directory_role_based_access_control {
    tenant_id          = var.tenant_id
    azure_rbac_enabled = var.az_rbac_enabled
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi-aks.id]
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  default_node_pool {
    name                        = var.np_name
    vm_size                     = var.np_vm_size
    vnet_subnet_id              = var.subnet_id
    node_count                  = var.np_node_count
    zones                       = var.av_zones
    temporary_name_for_rotation = var.temp_name_rotation
    orchestrator_version        = var.np_orch_ver

    upgrade_settings {
      max_surge = "10%"
    }

    tags = local.applied_tags
  }

  maintenance_window_node_os {
    frequency   = var.nos_freq
    interval    = var.nos_int
    duration    = var.nos_dur
    week_index  = var.nos_week
    day_of_week = var.nos_day_week
    start_time  = var.nos_start_time
    utc_offset  = var.utc_offset
  }

  network_profile {
    network_plugin      = var.net_plugin
    network_policy      = var.net_policy
    network_data_plane  = var.net_dp
    network_plugin_mode = var.net_pm
    load_balancer_sku   = var.lb_sku
    service_cidr        = var.svc_cidr
    dns_service_ip      = var.dns_svc_ip

  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings[0].max_surge, image_cleaner_interval_hours, upgrade_override
    ]
  }

  depends_on = [
    azurerm_user_assigned_identity.mi-aks,
    azurerm_role_assignment.mi-aks-dns,
  ]

  tags = local.applied_tags

}

