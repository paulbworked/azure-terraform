###############################################################
#               Network Security Groups & Associations        #
###############################################################

# Create Network Security Group for subnet with virtual machines hosted
resource "azurerm_network_security_group" "ops-nm-nsg" {
  name                = "nsg-opsNM-pab-ne"
  location            = var.region_ne
  resource_group_name = azurerm_resource_group.operations-rg.name

  tags = local.tags
}

# Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "nsg-nm-assoc" {
  subnet_id                 = azurerm_subnet.ops-nm-subnet.id
  network_security_group_id = azurerm_network_security_group.ops-nm-nsg.id
}

# Create Network Security Group for subnet with virtual machines hosted
resource "azurerm_network_security_group" "ops-vm-nsg" {
  name                = "nsg-opsVM-pab-ne"
  location            = var.region_ne
  resource_group_name = azurerm_resource_group.operations-rg.name

  tags = local.tags
}

# Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "nsg-vm-assoc" {
  subnet_id                 = azurerm_subnet.ops-vm-subnet.id
  network_security_group_id = azurerm_network_security_group.ops-vm-nsg.id
}

###############################################################
#               Virtual Network & Subnets                     #
###############################################################

# Create Virtual Network to host Operations resources
resource "azurerm_virtual_network" "operations-vnet" {
  name                = "vnet-ops-pab-ne"
  location            = var.region_ne
  resource_group_name = azurerm_resource_group.operations-rg.name
  # sanitised
  address_space = ["0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0"]

  tags = local.tags
}

# Create subnet to host network management devices
resource "azurerm_subnet" "ops-nm-subnet" {
  name                 = "snet-nm"
  resource_group_name  = azurerm_resource_group.operations-rg.name
  virtual_network_name = azurerm_virtual_network.operations-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  default_outbound_access_enabled = false

  lifecycle {
    ignore_changes = [private_endpoint_network_policies, ]
  }
}

# Create subnet to host virtual machines
resource "azurerm_subnet" "ops-vm-subnet" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.operations-rg.name
  virtual_network_name = azurerm_virtual_network.operations-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.KeyVault", "Microsoft.Storage"]
  default_outbound_access_enabled = false

  lifecycle {
    ignore_changes = [private_endpoint_network_policies, ]
  }
}

# Create subnet to host private endpoints
resource "azurerm_subnet" "ops-pep-subnet" {
  name                 = "snet-pep"
  resource_group_name  = azurerm_resource_group.operations-rg.name
  virtual_network_name = azurerm_virtual_network.operations-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.KeyVault", "Microsoft.Storage"]
  default_outbound_access_enabled = false

  lifecycle {
    ignore_changes = [private_endpoint_network_policies, ]
  }
}

# Create subnet to host container instances
resource "azurerm_subnet" "ops-ci-subnet" {
  name                 = "snet-ci"
  resource_group_name  = azurerm_resource_group.operations-rg.name
  virtual_network_name = azurerm_virtual_network.operations-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.KeyVault", "Microsoft.Storage"]
  default_outbound_access_enabled = false

  delegation {
    name = "container"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]

    }
  }

  lifecycle {
    ignore_changes = [delegation, private_endpoint_network_policies, ]
  }
}

# Create subnet to host Fabric Data Gateway
resource "azurerm_subnet" "ops-tg-subnet" {
  name                 = "snet-dg"
  resource_group_name  = azurerm_resource_group.operations-rg.name
  virtual_network_name = azurerm_virtual_network.operations-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.Storage"]
  default_outbound_access_enabled = false

  delegation {
    name = "datagateway"

    service_delegation {
      name    = "Microsoft.PowerPlatform/vnetaccesslinks"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]

    }
  }

  lifecycle {
    ignore_changes = [private_endpoint_network_policies, ]
  }
}

# Create subnet to host web apps
resource "azurerm_subnet" "ops-wapp-subnet" {
  name                 = "snet-wapp"
  resource_group_name  = azurerm_resource_group.operations-rg.name
  virtual_network_name = azurerm_virtual_network.operations-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.Web"]
  default_outbound_access_enabled = false

  delegation {
    name = "webapps"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", ]
    }
  }

  lifecycle {
    ignore_changes = [delegation, private_endpoint_network_policies, ]
  }
}

# Create subnet to host aks
resource "azurerm_subnet" "ops-aks-subnet" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.operations-rg.name
  virtual_network_name = azurerm_virtual_network.operations-vnet.name
  # sanitised
  address_prefixes                = ["0.0.0.0/0"]
  service_endpoints               = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
  default_outbound_access_enabled = false

  lifecycle {
    ignore_changes = [delegation, private_endpoint_network_policies, ]
  }
}

###############################################################
#               Private DNS Zone Links to VNET                #
###############################################################

#Link Private DNS Zone for pabcompany.internal to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-tt-ops-link" {
  name                  = "link-opsvnet-pabcompany"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-pabcompany.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for Key Vault to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-kv-ops-link" {
  name                  = "link-opsvnet-kvzone"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-kv.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for RSV Region NE to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-rsvne-ops-link" {
  name                  = "link-opsvnet-kvzone"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-rsvne.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for RSV Region WE to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-rsvwe-ops-link" {
  name                  = "link-opsvnet-kvzone"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-rsvwe.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for Queue Core to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-qcore-ops-link" {
  name                  = "link-opsvnet-qcore"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-qcore.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for Blob Core to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-bcore-ops-link" {
  name                  = "link-opsvnet-bcore"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-bcore.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for File Core to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-fcore-ops-link" {
  name                  = "link-opsvnet-fcore"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-fcore.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for Tables Core to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-tcore-ops-link" {
  name                  = "link-opsvnet-tcore"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-tcore.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for Data Link to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-dfscore-ops-link" {
  name                  = "link-opsvnet-dfscore"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-dfscore.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for Postgres to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-postgres-ops-link" {
  name                  = "link-opsvnet-postgres"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-postgres.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for Service Bus to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-servicebus-ops-link" {
  name                  = "link-opsvnet-servicebus"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-servicebus.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for App Service to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-appservice-ops-link" {
  name                  = "link-opsvnet-appservice"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-appservice.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for North Europe AKS to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-neaks-ops-link" {
  name                  = "link-opsvnet-neaks"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-ne-aks.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Private DNS Zone privatelink.westeurope.azmk8s.io
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-opradev-weaks-link" {
  name                  = "link-opsvnet-weaks"
  resource_group_name   = azurerm_resource_group.dns-ops-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pri-zone-we-aks.name
  virtual_network_id    = azurerm_virtual_network.operations-vnet.id
  registration_enabled  = false
}

# Link Private DNS Zone for Monitor to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "monitor_link" {
  name                  = "monitor-zone-link"
  resource_group_name   = local.dns_rg_name
  private_dns_zone_name = local.pri_dns_zone_monitor_name
  virtual_network_id    = local.ops_vnet_id
}

# Link Private DNS Zone for OMS to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "oms_link" {
  name                  = "oms-zone-link"
  resource_group_name   = local.dns_rg_name
  private_dns_zone_name = local.pri_dns_zone_oms_name
  virtual_network_id    = local.ops_vnet_id
}

# Link Private DNS Zone for ODS to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "ods_link" {
  name                  = "ods-zone-link"
  resource_group_name   = local.dns_rg_name
  private_dns_zone_name = local.pri_dns_zone_ods_name
  virtual_network_id    = local.ops_vnet_id
}

# Link Private DNS Zone for Agent Service to Operations VNET
resource "azurerm_private_dns_zone_virtual_network_link" "agentsvc_link" {
  name                  = "agentsvc-zone-link"
  resource_group_name   = local.dns_rg_name
  private_dns_zone_name = local.pri_dns_zone_agentsvc_name
  virtual_network_id    = local.ops_vnet_id
}

# Link Private DNS Zone for ACR
resource "azurerm_private_dns_zone_virtual_network_link" "acrsvc_link" {
  name                  = "acrsvc-zone-link"
  resource_group_name   = local.dns_rg_name
  private_dns_zone_name = local.pri_dns_zone_acr_name
  virtual_network_id    = local.ops_vnet_id
}

# Link Private DNS Zone for Azure SQL
resource "azurerm_private_dns_zone_virtual_network_link" "sqlsvc_link" {
  name                  = "sqlsvc-zone-link"
  resource_group_name   = local.dns_rg_name
  private_dns_zone_name = local.pri_dns_zone_sql_name
  virtual_network_id    = local.ops_vnet_id
}
