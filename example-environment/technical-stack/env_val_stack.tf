# Create resource group
resource "azurerm_resource_group" "pab-pab-rg" {
  name     = "rg-stack-pab"
  location = var.region_ne

  tags = local.tags
}
