# Create the network watcher resource group
resource "azurerm_resource_group" "ops-netwatch-rg" {
  name     = "rg-networkwatcher"
  location = "North Europe"

  tags = local.tags
}

# Create the network watcher for the NE region
resource "azurerm_network_watcher" "aznw-ops-ne" {
  name                = "NetworkWatcher_northeurope"
  resource_group_name = azurerm_resource_group.ops-netwatch-rg.name
  location            = "North Europe"

  tags = local.tags
}


# Create Log Analytics Workspace for network watcher flow logs
resource "azurerm_log_analytics_workspace" "aznw-law-ops" {
  name                       = "law-nw-pab-ne"
  resource_group_name        = azurerm_resource_group.ops-netwatch-rg.name
  location                   = "North Europe"
  sku                        = "PerGB2018"
  retention_in_days          = 30
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = local.tags
}

