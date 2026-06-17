data "azurerm_client_config" "current" {}

# Operations Key Vault
# Created with KV module but secrets and keys within were manually set up
module "kv-ops-ne" {
  source           = "app.terraform.io/pab-cloud-infrastructure/kv/azure"
  version          = "2.0.2"
  bus_stack        = "pab"
  env_stack        = "ops"
  loc_code         = "ne"
  region           = "North Europe"
  rg_name          = azurerm_resource_group.operations-rg.name
  sku              = "standard"
  public_enabled   = true
  rbac_enabled     = true
  subnet_id        = azurerm_subnet.ops-pep-subnet.id
  pri_zone_kv      = azurerm_private_dns_zone.pri-zone-kv.id
  subnet_id_ops-ci = azurerm_subnet.ops-ci-subnet.id
  kv_ips           = local.kv_ips
  resource_tags    = local.tags
}

#Create Key Vault Secret for DNSNE VM admin login
resource "azurerm_key_vault_secret" "dns-admin-log" {
  name         = "vm-dns-local-login"
  value        = "pabuser"
  key_vault_id = module.kv-ops-ne.kv-id
  content_type = "Local DNS VM admin login"
}

#Create DNSNE VM password
resource "random_password" "dns-ran-pass" {
  length      = 20
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  min_special = 1
  special     = true
}

#Create Key Vault Secret for DNSNE VM password
resource "azurerm_key_vault_secret" "dns-admin-pass" {
  name         = "vm-dns-local-password"
  value        = random_password.dns-ran-pass.result
  key_vault_id = module.kv-ops-ne.kv-id
  content_type = "Local DNS VM password"
}
