###############################################################
#                     Private DNS Zones                       #
###############################################################


# Create a DNS resource group
resource "azurerm_resource_group" "dns-ops-rg" {
  name     = "rg-dns"
  location = var.region_ne

  tags = local.tags
}

# Create Private DNS Zone for pabcompany.internal
resource "azurerm_private_dns_zone" "pri-zone-pabcompany" {
  name                = "pabcompany.internal"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "pri-zone-kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for RSV Region NE
resource "azurerm_private_dns_zone" "pri-zone-rsvne" {
  name                = "privatelink.ne.backup.windowsazure.com"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for RSV Region WE
resource "azurerm_private_dns_zone" "pri-zone-rsvwe" {
  name                = "privatelink.we.backup.windowsazure.com"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for Queue Core
resource "azurerm_private_dns_zone" "pri-zone-qcore" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for Blob Core
resource "azurerm_private_dns_zone" "pri-zone-bcore" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for File Core
resource "azurerm_private_dns_zone" "pri-zone-fcore" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for Table Core
resource "azurerm_private_dns_zone" "pri-zone-tcore" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for Data Lake Store
resource "azurerm_private_dns_zone" "pri-zone-dfscore" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for Postgres
resource "azurerm_private_dns_zone" "pri-zone-postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for Service Bus
resource "azurerm_private_dns_zone" "pri-zone-servicebus" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for App Service
resource "azurerm_private_dns_zone" "pri-zone-appservice" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for North Europe AKS
resource "azurerm_private_dns_zone" "pri-zone-ne-aks" {
  name                = "privatelink.northeurope.azmk8s.io"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for West Europe AKS
resource "azurerm_private_dns_zone" "pri-zone-we-aks" {
  name                = "privatelink.westeurope.azmk8s.io"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for Monitor
resource "azurerm_private_dns_zone" "pri-zone-azmon" {
  name                = "privatelink.monitor.azure.com"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for OMS endpoints
resource "azurerm_private_dns_zone" "pri-zone-omsopin" {
  name                = "privatelink.oms.opinsights.azure.com"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for ODS endpoints
resource "azurerm_private_dns_zone" "pri-zone-odsopin" {
  name                = "privatelink.ods.opinsights.azure.com"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for agent service automation endpoints
resource "azurerm_private_dns_zone" "pri-zone-agsvcauto" {
  name                = "privatelink.agentsvc.azure-automation.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for acr endpoints
resource "azurerm_private_dns_zone" "pri-zone-acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}

# Create Private DNS Zone for Azure SQL
resource "azurerm_private_dns_zone" "pri-zone-sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.dns-ops-rg.name

  tags = local.tags
}
