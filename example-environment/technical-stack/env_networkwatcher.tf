# Create the network watcher resource group
resource "azurerm_resource_group" "pab-netwatch-rg" {
  name     = "rg-networkwatcher-pab"
  location = var.region_ne

  tags = local.tags
}

# Create the network watcher for the NE region
resource "azurerm_network_watcher" "aznw-ne" {
  name                = "NetworkWatcher_northeurope"
  resource_group_name = azurerm_resource_group.pab-netwatch-rg.name
  location            = "North Europe"

  tags = local.tags

}
