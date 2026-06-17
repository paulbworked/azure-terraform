# RG for the PAB environment stack
resource "azurerm_resource_group" "pab-pab-rg" {
  name     = "rg-pab"
  location = var.region_ne

  tags = local.tags
}


# Storage Account for environment stack
module "pabapppabne" {
  source       = "app.terraform.io/pab-cloud-infrastructure/sa/azure"
  version      = "2.0.1"
  bus_stack    = "pab"
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

  subnet_id        = local.snet_pep
  pri_zone_sa_blob = local.dns_sabc

}

# Uses the Data module
module "data-pab" {
  source    = "app.terraform.io/pab-cloud-infrastructure/data/azure"
  version   = "2026.1.12"
  tenant_id = var.tenant_id
  bus_stack = "pab"
  env_stack = "pab"
  loc_code  = "ne"
  region    = var.region_ne
  rg_name   = azurerm_resource_group.pab-pab-rg.name
  # sanitised
  postgres_version           = "0"
  psql_username              = azurerm_key_vault_secret.pab-psqllogin.value
  psql_kvs                   = azurerm_key_vault_secret.pab-psqlsecret.value
  subnet_id_psql             = local.snet_psql
  pri_dns_zone_id_psql       = local.dns_psql
  psql_sku                   = local.psql_sku.pab
  psql_backup_retention_days = 7
  # sanitised
  psql_storage_tier            = "0"
  psql_storage_mb              = 131072
  geo_redundant_backup_enabled = false
  psql_max_con                 = 200
  psql_max_prep_tran           = 200

  sbns_sku             = local.sbns_sku.standard
  sbns_pub_acc_en      = "true"
  pri_dns_zone_id_sbns = local.dns_sbns
  sbns_nfs_def_action  = "Deny"
  sbns_ip_rules        = local.sbns_ip_ruleset
  sbns_snet_id         = local.snet_id
  sp_core              = local.service_principal.qual_core
  sp_reportservice     = local.service_principal.qual_reportservice

  at_org_id        = local.kvs_atoid
  at_cloudops_team = local.at_cloudopsteam
  at_role_names    = local.at_role_names
  # sanitised
  mg_proj_ip_whitelist = "0.0.0.0"
  mg_cluster_type      = "REPLICASET"
  # sanitised
  mg_instance_size = "0"
  mg_node_count    = 3
  mg_disk_size_gb  = 64
  mg_priority      = 7
  mg_region_name   = "EUROPE_NORTH"
  # sanitised
  mg_db_version      = "0"
  mg_disk_gb_enabled = false
  mg_pit_enabled     = false
  mg_backup_enabled  = true
  mg_oplog_size      = 10000
  subnet_id_pep      = local.snet_pep
  mg_az_reg_name     = "northeurope"
  kv_id              = module.kv-pab-pab-ne.kv-id

  resource_tags = local.tags

}

resource "azurerm_postgresql_flexible_server_configuration" "pab-pab-pg-az-ext" {
  name      = "azure.extensions"
  server_id = module.data-pab-pab-ne.psql-id
  value     = "CITEXT"

  depends_on = [module.data-pab-pab-ne]

}
