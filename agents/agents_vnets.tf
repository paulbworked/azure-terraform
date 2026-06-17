###############################################################
#               Network Security Groups & Associations        #
###############################################################



###############################################################
#               Virtual Network & Subnets                     #
###############################################################

# Create Virtual Network to host Agent resources
resource "azurerm_virtual_network" "agents-vnet" {
  name                = "vnet-agents-ne"
  location            = var.region_ne
  resource_group_name = azurerm_resource_group.agents-rg.name
  # sanitised
  address_space = ["0.0.0.0/0"]

  tags = local.tags
}

# Create subnet to host virtual machines
resource "azurerm_subnet" "ag-subnet" {
  name                 = "snet-ag"
  resource_group_name  = azurerm_resource_group.agents-rg.name
  virtual_network_name = azurerm_virtual_network.agents-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.Storage"]
  default_outbound_access_enabled = false

  lifecycle {
    ignore_changes = [private_endpoint_network_policies, ]
  }

}

###############################################################
#                   VNET links to VWAN                        #
###############################################################

resource "azurerm_virtual_hub_connection" "wan-hub-agentvnet" {
  name                      = "peer-hubne-vnetagentne"
  virtual_hub_id            = local.vwan_hubid
  remote_virtual_network_id = azurerm_virtual_network.agents-vnet.id
  internet_security_enabled = true
}

###############################################################
#               Private DNS Zone Links to VNET                #
###############################################################

# Private DNS Zone company internal
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-tt-link" {
  name                  = "link-pabag-tt"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_internal_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.vaultcore.azure.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-kvc-link" {
  name                  = "link-pabag-kvc"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_kvvc_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.ne.backup.windowsazure.com
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-nersv-link" {
  name                  = "link-pabag-nersv"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_nersv_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.we.backup.windowsazure.com
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-opabag-rsvwe-link" {
  name                  = "link-pabag-wersv"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_wersv_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}


# Private DNS Zone privatelink.queue.core.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-saqc-link" {
  name                  = "link-pabag-saqc"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_saqc_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.blob.core.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-sabc-link" {
  name                  = "link-pabag-saqc"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_sabc_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.file.core.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-safc-link" {
  name                  = "link-pabag-safc"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_safc_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.dfs.core.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-sadfs-link" {
  name                  = "link-pabag-dfs"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_sadfs_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.postgres.database.azure.com
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-psql-link" {
  name                  = "link-pabag-psql"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_psql_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.servicebus.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-sbs-link" {
  name                  = "link-pabag-sbs"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_sbs_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.azurewebsites.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-apps-link" {
  name                  = "link-pabag-apps"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_apps_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.northeurope.azmk8s.io
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-neaks-link" {
  name                  = "link-pabag-neaks"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_neaks_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.westeurope.azmk8s.io
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-weaks-link" {
  name                  = "link-pabag-weaks"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_weaks_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.azurecr.io
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-acr-link" {
  name                  = "link-pabpag-acr"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_acr_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}

# Private DNS Zone Azure SQL
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabag-sql-link" {
  name                  = "link-pabpag-sql"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_sql_n
  virtual_network_id    = azurerm_virtual_network.agents-vnet.id
  registration_enabled  = false
}
