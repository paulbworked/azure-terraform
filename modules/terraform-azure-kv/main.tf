locals {
  mandatory_tags = {
    source  = "terraform"
    company = "pab"
  }
  applied_tags = merge(var.resource_tags, local.mandatory_tags)
}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-${var.bus_stack}-${var.env_stack}-${var.loc_code}"
  location                      = var.region
  resource_group_name           = var.rg_name
  enabled_for_disk_encryption   = true
  tenant_id                     = "00000000-0000-0000-0000-000000000000"
  soft_delete_retention_days    = 30
  purge_protection_enabled      = false
  sku_name                      = var.sku
  public_network_access_enabled = var.public_enabled
  rbac_authorization_enabled    = var.rbac_enabled

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = var.kv_ips
    virtual_network_subnet_ids = [var.subnet_id_ops-ci]
  }

  tags = local.applied_tags

}

resource "azurerm_private_endpoint" "pep" {
  name                          = "${azurerm_key_vault.kv.name}-pep"
  location                      = var.region
  resource_group_name           = var.rg_name
  custom_network_interface_name = "${azurerm_key_vault.kv.name}-pep-nic"
  subnet_id                     = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.env_stack}${var.bus_stack}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["Vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.pri_zone_kv]
  }

  tags = local.applied_tags
}

