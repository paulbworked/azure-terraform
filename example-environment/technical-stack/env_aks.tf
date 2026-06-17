module "aks-pab" {
  source                 = "app.terraform.io/pab-cloud-infrastructure/aks/azure"
  version                = "2.0.9"
  bus_stack              = "pab"
  env_stack              = "pab"
  loc_code               = "ne"
  region                 = "North Europe"
  dns_scope              = local.aks_dns_scope
  vnet_scope             = local.val_vnet_scope
  acr_scope              = local.acr_scope
  sku_tier               = "Standard"
  pri_cluster_enabled    = true
  pri_dns_zone_id        = local.dns_neaks
  pub_fqdn_enabled       = false
  http_app_route_enabled = false
  rbac_enabled           = true
  local_acc_disabled     = false
  tenant_id              = local.tenant_id
  az_rbac_enabled        = true
  # sanitised
  kubes_version = "0.00"
  # sanitised
  np_orch_ver        = "0.00"
  np_name            = "appab"
  np_vm_size         = "Standard_D8s_v4"
  subnet_id          = azurerm_subnet.pab-aks-pab-snet.id
  np_node_count      = "3"
  av_zones           = local.av_zones
  temp_name_rotation = "pabtemppool"
  nos_freq           = "RelativeMonthly"
  nos_int            = "1"
  nos_dur            = "4"
  nos_week           = "Second"
  nos_day_week       = "Wednesday"
  nos_start_time     = "03:00"
  utc_offset         = "+00:00"
  net_plugin         = "azure"
  net_policy         = "cilium"
  net_dp             = "cilium"
  net_pm             = "overlay"
  lb_sku             = "standard"
  # sanitised
  svc_cidr = "0.0.0.0/0"
  # sanitised
  dns_svc_ip    = "0.0.0.0"
  resource_tags = local.tags
}

# Adding a temporary node pool for the CM2 Importer
resource "azurerm_kubernetes_cluster_node_pool" "aks-pool" {
  name                        = "appabval2"
  kubernetes_cluster_id       = local.aks_val_id
  vm_size                     = "Standard_D16as_v7"
  node_count                  = 0
  vnet_subnet_id              = azurerm_subnet.pab-aks-pab-snet.id
  zones                       = ["2", "3"] # Apparently zone 1 is not supported in North Europe
  temporary_name_for_rotation = "pabtemppool2"
  orchestrator_version        = "0.00"

  node_taints = [
    "dedicated=cm2-importer:NoSchedule"
  ]

  upgrade_settings {
    max_surge = "10%"
  }

  depends_on = [module.aks-pab]

  tags = local.tags
}

# KEEPING THIS IN FOR NOW AS WILL NEED TO CHANGE THE ABOVE CUT AND PASTE CODE TO ACCOMODATE MAINENANCE WINDOWS

# DEV = Monday
# UQ = Tuesday
# pab = Wednesday
# PAB = Wednesday
# PROD = Thursday

# so that is every variable starting nos_

# frequency   = "RelativeMonthly"
# Frequency of maintenance. Possible options are Daily, Weekly, AbsoluteMonthly and RelativeMonthly.
# AbsoluteMonthly is based on a specific date each month, while RelativeMonthly is based on a specific day of the week within a particular week of the month

# interval = "1"
# The interval for maintenance runs. Depending on the frequency this interval is week or month based.

# duration = "4"
# The duration of the window for maintenance to run in hours. Possible options are between 4 to 24.
# The duration should be specified in the ISO 8601 duration format. For example, if you want the duration to be 4 hours, it should be PT4H.

# week_index  = "First"
# The week in the month used for the maintenance run. Options are First, Second, Third, Fourth, and Last.

# day_of_week = "Sunday"
# The day of the week for the maintenance run. Required in combination with weekly frequency. Possible values are Friday, Monday, Saturday, Sunday, Thursday, Tuesday and Wednesday.

# start_time  = "03:00"
# The time for maintenance to begin, based on the timezone determined by utc_offset. Format is HH:mm.

# utc_offset  = "+00:00"
# Used to determine the timezone for cluster maintenance.
