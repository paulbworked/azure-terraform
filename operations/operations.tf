# Create an Operations resource group
resource "azurerm_resource_group" "operations-rg" {
  name     = "rg-ops"
  location = var.region_ne

  tags = local.tags
}

# LAW for storage account auditing of xdrive and sftp resources
resource "azurerm_log_analytics_workspace" "law-auditsa-ops" {
  name                       = "law-auditsa-ops"
  resource_group_name        = azurerm_resource_group.operations-rg.name
  location                   = var.region_ne
  sku                        = "PerGB2018"
  retention_in_days          = 30
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = local.tags
}
