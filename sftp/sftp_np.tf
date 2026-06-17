###############################################################
#                        Resource Group                       #
###############################################################

# Create resource group
resource "azurerm_resource_group" "sftp-rg" {
  name     = "rg-sftp"
  location = var.region_ne

  tags = local.tags
}

###############################################################
#                NonProd Storage Account                      #
###############################################################

# Storage Account to be used for SFTP
resource "azurerm_storage_account" "np-sa-sftp" {
  name                          = "pabsftpnp"
  resource_group_name           = azurerm_resource_group.sftp-rg.name
  location                      = var.region_ne
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  access_tier                   = "Hot"
  account_replication_type      = "ZRS"
  public_network_access_enabled = true
  is_hns_enabled                = true
  # HNS is required to enable SFTP
  nfsv3_enabled            = false
  sftp_enabled             = true
  large_file_share_enabled = true
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled  = "false"
    change_feed_enabled = "false"
    # these cannot be set to true when HNS is enabled

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }

  }

  network_rules {
    default_action = "Deny"
    # sanitised
    ip_rules                   = ["0.0.0.0", "0.0.0.0"]
    virtual_network_subnet_ids = tolist(local.vnet_snet_ids)
  }

  lifecycle {
    ignore_changes = [
    blob_properties]
  }

  tags = local.tags

}

# Private Endpoint for Blob Containers
resource "azurerm_private_endpoint" "np-sa-sftp-blob-pep" {
  name                          = "${azurerm_storage_account.np-sa-sftp.name}b-pep"
  location                      = var.region_ne
  resource_group_name           = azurerm_resource_group.sftp-rg.name
  custom_network_interface_name = "${azurerm_storage_account.np-sa-sftp.name}b-pep-nic"
  subnet_id                     = local.snet_ops_pep

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.np-sa-sftp.name}-b"
    private_connection_resource_id = azurerm_storage_account.np-sa-sftp.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.dns_sabc]
  }

  tags = local.tags
}

# Private Endpoint for Data Lake Containers
resource "azurerm_private_endpoint" "np-sa-sftp-dfs-pep" {
  name                          = "${azurerm_storage_account.np-sa-sftp.name}dfs-pep"
  location                      = var.region_ne
  resource_group_name           = azurerm_resource_group.sftp-rg.name
  custom_network_interface_name = "${azurerm_storage_account.np-sa-sftp.name}dfs-pep-nic"
  subnet_id                     = local.snet_ops_pep

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.np-sa-sftp.name}-b"
    private_connection_resource_id = azurerm_storage_account.np-sa-sftp.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.dns_sadfs]
  }

  tags = local.tags

}

# Log and monitor of file activity of Storage Account
resource "azurerm_monitor_diagnostic_setting" "np-sftp-auditsa-law" {
  name                       = "${azurerm_storage_account.np-sa-sftp.name}-blobDiagnostics"
  target_resource_id         = "${azurerm_storage_account.np-sa-sftp.id}/blobServices/default"
  log_analytics_workspace_id = local.law_auditsa

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }

  enabled_metric {
    category = "Capacity"
  }

  # lifecycle {
  #   ignore_changes = [ metric ]
  # }

}
