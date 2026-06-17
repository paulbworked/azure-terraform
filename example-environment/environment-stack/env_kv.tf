# Generic Key Vault for env stack
module "kv-pab-pab-ne" {
  source           = "app.terraform.io/pab-cloud-infrastructure/kv/azure"
  version          = "2.0.2"
  bus_stack        = "pab"
  env_stack        = "pab"
  loc_code         = "ne"
  region           = "North Europe"
  rg_name          = azurerm_resource_group.pab-pab-rg.name
  sku              = "standard"
  public_enabled   = true
  rbac_enabled     = true
  subnet_id        = local.snet_pep
  pri_zone_kv      = local.dns_kvvc
  subnet_id_ops-ci = local.snet_cis
  kv_ips           = local.kv_ips
  resource_tags    = local.tags
}

# I have removed a load of secrets set up as part of this
