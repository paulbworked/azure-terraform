###############################################################
#                   Recovery Services Vault                   #
###############################################################

# RG to host the RSV
resource "azurerm_resource_group" "pab-rsv-rg" {
  name     = "rg-rsv-pab"
  location = var.region_ne

  tags = local.tags
}

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "rsv-pab" {
  name                          = "rsv-pab-ne"
  location                      = var.region_ne
  resource_group_name           = azurerm_resource_group.pab-rsv-rg.name
  sku                           = "Standard"
  public_network_access_enabled = false
  storage_mode_type             = "LocallyRedundant"

  tags = local.tags
}

# Private Endpoint for Recovery Services Vault
resource "azurerm_private_endpoint" "pep-valne-rsv" {
  name                          = "rsv-pab-ne-pep"
  location                      = var.region_ne
  resource_group_name           = azurerm_resource_group.pab-rsv-rg.name
  subnet_id                     = azurerm_subnet.pab-pep-pab-snet.id
  custom_network_interface_name = "rsv-pab-ne-pep-nic"

  private_service_connection {
    name                           = "psc-valrsvne"
    private_connection_resource_id = azurerm_recovery_services_vault.rsv-pab.id
    subresource_names              = ["AzureBackup"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.dns_nersv]
  }
  tags = local.tags
}

###############################################################
#        Virtual Machine Policies & Virtual Machines          #
###############################################################

# Weekly Backup Policy for virtual machines
resource "azurerm_backup_policy_vm" "rsv-pab-bp-wvm" {
  name                           = "pab-weekly-policy-vm"
  resource_group_name            = azurerm_resource_group.pab-rsv-rg.name
  recovery_vault_name            = azurerm_recovery_services_vault.rsv-pab.name
  instant_restore_retention_days = 5

  timezone = "GMT Standard Time"

  instant_restore_resource_group {
    prefix = "rg-rsv-pab-backupRG-"
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

# Daily Backup Policy for virtual machines
resource "azurerm_backup_policy_vm" "rsv-pab-bp-dvm" {
  name                           = "pab-daily-policy-vm"
  resource_group_name            = azurerm_resource_group.pab-rsv-rg.name
  recovery_vault_name            = azurerm_recovery_services_vault.rsv-pab.name
  instant_restore_retention_days = 5

  timezone = "GMT Standard Time"

  instant_restore_resource_group {
    prefix = "rg-rsv-pab-backupRG-"
  }

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }
}

# pab pab virtual machine weekly backup
resource "azurerm_backup_protected_vm" "rsv-pabvalvm-backup" {
  resource_group_name = azurerm_resource_group.pab-rsv-rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv-pab.name
  source_vm_id        = local.vmpabvalne
  backup_policy_id    = azurerm_backup_policy_vm.rsv-pab-bp-wvm.id
}

###############################################################
#        Storage Account Policies & Storage Accounts          #
###############################################################

# Daily Backup Policy for storage account file shares
resource "azurerm_backup_policy_file_share" "rsv-pab-bp-dsa" {
  name                = "pab-daily-policy-safs"
  resource_group_name = azurerm_resource_group.pab-rsv-rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv-pab.name

  timezone = "GMT Standard Time"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 90
  }

}

# pab pab xdrive storage account backup protection
resource "azurerm_backup_container_storage_account" "rsv-pabappxdvalnesa-protection" {
  resource_group_name = azurerm_resource_group.pab-rsv-rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv-pab.name
  storage_account_id  = local.sa_val_xd
}

# pab pab xdrive storage account daily backup
resource "azurerm_backup_protected_file_share" "rsv-pabappxdvalnesa-backup" {
  resource_group_name       = azurerm_resource_group.pab-rsv-rg.name
  recovery_vault_name       = azurerm_recovery_services_vault.rsv-pab.name
  source_storage_account_id = local.sa_val_xd
  source_file_share_name    = local.sa_val_sx_ss
  backup_policy_id          = azurerm_backup_policy_file_share.rsv-pab-bp-dsa.id

  depends_on = [azurerm_backup_container_storage_account.rsv-pabappxdvalnesa-protection]
}
