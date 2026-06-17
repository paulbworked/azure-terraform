# Generic Storage Account for pab stack
module "pabappstackvalne" {
  source  = "app.terraform.io/pab-cloud-infrastructure/sa/azure"
  version = "2.0.1"

  bus_stack    = "pabstack"
  env_stack    = "pab"
  loc_code     = "ne"
  rg_name      = azurerm_resource_group.pab-pab-rg.name
  region       = "North Europe"
  acc_kind     = "StorageV2"
  acc_tier     = "Standard"
  acc_rep_type = "GRS"
  pub_net_acc  = "false"
  hns_enabled  = "false"
  # if above is true then see link for other requisites 
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#is_hns_enabled
  nfs_enabled = "false"
  # if above is true then see link for other requisites 
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#nfsv3_enabled
  sftp_enabled = "false"
  # if above is true then see link for other requisites 
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#sftp_enabled
  ver_enabled       = "true"
  chan_feed_enabled = "true"
  # Both above set to true to use the restore policy
  blob_ret_days = 7
  con_ret_days  = 7
  restore_days  = 3
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#restore_policy
  resource_tags = local.tags

  subnet_id        = azurerm_subnet.pab-pep-pab-snet.id
  pri_zone_sa_blob = local.dns_sabc

}
