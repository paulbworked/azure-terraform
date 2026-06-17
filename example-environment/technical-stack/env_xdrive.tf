###############################################################
#                       Storage Account                       #
###############################################################
resource "azurerm_storage_account" "pab-sa-xd-pab" {
  name                          = "pabappxdpabne"
  resource_group_name           = azurerm_resource_group.pab-pab-rg.name
  location                      = var.region_ne
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  access_tier                   = "Hot"
  account_replication_type      = "GRS"
  public_network_access_enabled = true
  is_hns_enabled                = false
  nfsv3_enabled                 = false
  sftp_enabled                  = false
  large_file_share_enabled      = true
  min_tls_version               = "TLS1_2"

  blob_properties {
    versioning_enabled  = "true"
    change_feed_enabled = "true"

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }

    restore_policy {
      days = 3
    }

  }


  network_rules {
    default_action             = "Deny"
    ip_rules                   = local.kv_ips
    virtual_network_subnet_ids = [azurerm_subnet.pab-vm-pab-snet.id]
  }

  tags = local.tags

}

###############################################################
#                       Private Endpoints                     #
###############################################################

resource "azurerm_private_endpoint" "pab-blob-pep-xd-pab" {
  name                          = "${azurerm_storage_account.pab-sa-xd-pab.name}-b-pep"
  location                      = var.region_ne
  resource_group_name           = azurerm_resource_group.pab-pab-rg.name
  custom_network_interface_name = "${azurerm_storage_account.pab-sa-xd-pab.name}-b-pep-nic"
  subnet_id                     = azurerm_subnet.pab-pep-pab-snet.id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.pab-sa-xd-pab.name}"
    private_connection_resource_id = azurerm_storage_account.pab-sa-xd-pab.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.dns_sabc]
  }
  tags = local.tags
}

resource "azurerm_private_endpoint" "pab-fs-pep-xd-pab" {
  name                          = "${azurerm_storage_account.pab-sa-xd-pab.name}-fs-pep"
  location                      = var.region_ne
  resource_group_name           = azurerm_resource_group.pab-pab-rg.name
  custom_network_interface_name = "${azurerm_storage_account.pab-sa-xd-pab.name}-fs-pep-nic"
  subnet_id                     = azurerm_subnet.pab-pep-pab-snet.id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.pab-sa-xd-pab.name}"
    private_connection_resource_id = azurerm_storage_account.pab-sa-xd-pab.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.dns_safc]
  }
  tags = local.tags
}

###############################################################
#                       File Share                            #
###############################################################

resource "azurerm_storage_share" "pab-sa-ss-xd-pab" {
  name               = "xdrive"
  storage_account_id = azurerm_storage_account.pab-sa-xd-pab.id
  quota              = 1024
  access_tier        = "Hot"

  depends_on = [azurerm_storage_account.pab-sa-xd-pab]
}

###############################################################
#                    File Share Logging                       #
###############################################################

resource "azurerm_monitor_diagnostic_setting" "pabappxdpabne-auditsa-law" {
  name                       = "pabappxdpabne-fileDiagnostics"
  target_resource_id         = "${azurerm_storage_account.pab-sa-xd-pab.id}/fileServices/default"
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
  #   ignore_changes = [metric]
  # }

}

###############################################################
#                    File Share Backup                        #
###############################################################

# The file share is backed by the RSV in the UNQ workspace
