###############################################################
#                   Recovery Services Vault                   #
###############################################################

# RG to host the RSV
resource "azurerm_resource_group" "rsv-ops-rg" {
  name     = "rg-rsv"
  location = var.region_ne

  tags = local.tags
}

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "rsv-ops" {
  name                          = "rsv-ops"
  location                      = var.region_ne
  resource_group_name           = azurerm_resource_group.rsv-ops-rg.name
  sku                           = "Standard"
  public_network_access_enabled = false
  storage_mode_type             = "LocallyRedundant"

  tags = local.tags
}

# Private Endpoint for Recovery Services Vault
resource "azurerm_private_endpoint" "pep-opsne-rsv" {
  name                          = "rsv-ops-pep"
  location                      = var.region_ne
  resource_group_name           = azurerm_resource_group.rsv-ops-rg.name
  subnet_id                     = azurerm_subnet.ops-pep-subnet.id
  custom_network_interface_name = "rsv-ops-pep-nic"

  private_service_connection {
    name                           = "psc-opsrsvne"
    private_connection_resource_id = azurerm_recovery_services_vault.rsv-ops.id
    subresource_names              = ["AzureBackup"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
    azurerm_private_dns_zone.pri-zone-rsvne.id]
  }

  tags = local.tags
}

###############################################################
#                   Virtual Machine Policies                  #
###############################################################

# Weekly Backup Policy for virtual machines
resource "azurerm_backup_policy_vm" "rsv-ops-bp-wvm" {
  name                           = "ops-weekly-policy-vm"
  resource_group_name            = azurerm_resource_group.rsv-ops-rg.name
  recovery_vault_name            = azurerm_recovery_services_vault.rsv-ops.name
  instant_restore_retention_days = 5

  timezone = "GMT Standard Time"

  instant_restore_resource_group {
    prefix = "rg-rsv-backupRG-"
  }

  backup {
    frequency = "Weekly"
    time      = "23:00"
    weekdays  = ["Sunday"]
  }

  retention_weekly {
    count    = 10
    weekdays = ["Sunday"]
  }
}

# Add to vmdnsne to weekly backup policy for virtual machines
resource "azurerm_backup_protected_vm" "rsv-backup" {
  resource_group_name = azurerm_resource_group.rsv-ops-rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv-ops.name
  source_vm_id        = local.vmdnsne
  backup_policy_id    = azurerm_backup_policy_vm.rsv-ops-bp-wvm.id
}

###############################################################
#                   Storage Account Policies                  #
###############################################################

# Daily Backup Policy for storage account file shares
resource "azurerm_backup_policy_file_share" "rsv-ops-bp-dsa" {
  name                = "ops-daily-policy-safs"
  resource_group_name = azurerm_resource_group.rsv-ops-rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv-ops.name

  timezone = "GMT Standard Time"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 90
  }

}

# Register paboprasftpprod storage account to RSV to allow backups
resource "azurerm_backup_container_storage_account" "rsv-back-paboprasftpprod" {
  resource_group_name = azurerm_resource_group.rsv-ops-rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv-ops.name
  storage_account_id  = local.sa_sftp_prod

}

# Backup File Share
resource "azurerm_backup_protected_file_share" "rsv-backup-pabopssftppocne" {
  resource_group_name       = azurerm_resource_group.rsv-ops-rg.name
  recovery_vault_name       = azurerm_recovery_services_vault.rsv-ops.name
  source_storage_account_id = azurerm_storage_account.ops-sa-xd.id
  source_file_share_name    = azurerm_storage_share.sa-xd-fs.name
  backup_policy_id          = azurerm_backup_policy_file_share.rsv-ops-bp-dsa.id

  depends_on = [azurerm_backup_container_storage_account.rsv-back-pabopssftppocne]
}
