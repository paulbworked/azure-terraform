locals {
  mandatory_tags = {
    source  = "terraform"
    company = "pab"
  }
  applied_tags = merge(var.resource_tags, local.mandatory_tags)
}

resource "azurerm_storage_account" "sa" {
  name                          = "pab${var.bus_stack}${var.env_stack}${var.loc_code}"
  resource_group_name           = var.rg_name
  location                      = var.region
  account_kind                  = var.acc_kind
  account_tier                  = var.acc_tier
  account_replication_type      = var.acc_rep_type
  public_network_access_enabled = var.pub_net_acc
  is_hns_enabled                = var.hns_enabled
  # if above is true then see link for other requisites 
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#is_hns_enabled
  nfsv3_enabled = var.nfs_enabled
  # if above is true then see link for other requisites 
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#nfsv3_enabled
  sftp_enabled = var.sftp_enabled
  # if above is true then see link for other requisites 
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#sftp_enabled

  blob_properties {
    versioning_enabled  = var.ver_enabled
    change_feed_enabled = var.chan_feed_enabled
    # Both above set to true to use the restore policy

    delete_retention_policy {
      days = var.blob_ret_days
    }

    container_delete_retention_policy {
      days = var.con_ret_days
    }

    restore_policy {
      days = var.restore_days
    }
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#restore_policy
  }

  tags = local.applied_tags

}

resource "azurerm_private_endpoint" "sa_blob_pep" {
  name                          = "${azurerm_storage_account.sa.name}-pep"
  location                      = var.region
  resource_group_name           = var.rg_name
  custom_network_interface_name = "${azurerm_storage_account.sa.name}-pep-nic"
  subnet_id                     = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.env_stack}${var.bus_stack}"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.pri_zone_sa_blob]
  }

  tags = local.applied_tags
}
