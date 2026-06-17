###############################################################
#               Network Security Groups & Associations        #
###############################################################

# Create Network Security Group for subnet with virtual machines hosted
resource "azurerm_network_security_group" "pab-vm-pab-nsg" {
  name                = "nsg-pabVM-pab-ne"
  location            = var.region_ne
  resource_group_name = azurerm_resource_group.pab-pab-rg.name

  tags = local.tags

}

# Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "nsg-vm-assoc" {
  subnet_id                 = azurerm_subnet.pab-vm-pab-snet.id
  network_security_group_id = azurerm_network_security_group.pab-vm-pab-nsg.id
}

###############################################################
#               Virtual Network & Subnets                     #
###############################################################

# Create Virtual Network to host Operations resources
resource "azurerm_virtual_network" "pab-pab-vnet" {
  name                = "vnet-pab-pab-ne"
  location            = var.region_ne
  resource_group_name = azurerm_resource_group.pab-pab-rg.name
  # sanitised
  address_space = ["0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0"]

  tags = local.tags

}

# Create subnet to host AKS
resource "azurerm_subnet" "pab-aks-pab-snet" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.pab-pab-rg.name
  virtual_network_name = azurerm_virtual_network.pab-pab-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.ServiceBus"]
  default_outbound_access_enabled = false

  lifecycle {
    ignore_changes = [private_endpoint_network_policies, ]
  }
}

# Create subnet to host virtual machines
resource "azurerm_subnet" "pab-vm-pab-snet" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.pab-pab-rg.name
  virtual_network_name = azurerm_virtual_network.pab-pab-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.Storage"]
  default_outbound_access_enabled = false

  lifecycle {
    ignore_changes = [private_endpoint_network_policies, ]
  }
}

# Create subnet to host private endpoints
resource "azurerm_subnet" "pab-pep-pab-snet" {
  name                 = "snet-pep"
  resource_group_name  = azurerm_resource_group.pab-pab-rg.name
  virtual_network_name = azurerm_virtual_network.pab-pab-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.Storage", "Microsoft.ServiceBus"]
  default_outbound_access_enabled = false

  lifecycle {
    ignore_changes = [private_endpoint_network_policies, ]
  }
}

# Create subnet to host postgres
resource "azurerm_subnet" "pab-psql-pab-snet" {
  name                 = "snet-psql"
  resource_group_name  = azurerm_resource_group.pab-pab-rg.name
  virtual_network_name = azurerm_virtual_network.pab-pab-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.Storage"]
  default_outbound_access_enabled = false

  delegation {
    name = "postgres"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", ]
    }
  }

  lifecycle {
    ignore_changes = [private_endpoint_network_policies, ]
  }
}

###############################################################
#                   VNET links to VWAN                        #
###############################################################

resource "azurerm_virtual_hub_connection" "wan-hub-pabvnet" {
  provider                  = azurerm.ops
  name                      = "peer-hubne-vnetpabne"
  virtual_hub_id            = local.vwan_hubid
  remote_virtual_network_id = azurerm_virtual_network.pab-pab-vnet.id
  internet_security_enabled = true
}

###############################################################
#               Private DNS Zone Links to VNET                #
###############################################################

# Private DNS Zone pabcompany.internal
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-tt-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-tt"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_tri_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.vaultcore.azure.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-kvc-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-kvc"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_kvvc_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.ne.backup.windowsazure.com
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-nersv-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-nersv"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_nersv_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.we.backup.windowsazure.com
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-rsvwe-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-wersv"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_wersv_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.queue.core.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-saqc-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-saqc"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_saqc_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.blob.core.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-sabc-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-saqc"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_sabc_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.file.core.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-safc-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-safc"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_safc_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.dfs.core.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-sadfs-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-dfs"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_sadfs_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}


# Private DNS Zone privatelink.postgres.database.azure.com
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-psql-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-psql"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_psql_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.servicebus.windows.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-sbs-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-sbs"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_sbs_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.azurewebsites.net
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-apps-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-apps"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_apps_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.northeurope.azmk8s.io
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-neaks-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-neaks"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_neaks_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.westeurope.azmk8s.io
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-weaks-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-weaks"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_weaks_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.azurecr.io
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-acr-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-acr"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_acr_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}

# Private DNS Zone Azure SQL
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-pabpab-sql-link" {
  provider              = azurerm.ops
  name                  = "link-pabpab-sql"
  resource_group_name   = local.rg_dns
  private_dns_zone_name = local.dns_sql_n
  virtual_network_id    = azurerm_virtual_network.pab-pab-vnet.id
  registration_enabled  = false
}
