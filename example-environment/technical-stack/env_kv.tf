# A generic Key Vault for the pab technical stack used by all pab environment stacks
module "kv-pab-pab-stack" {
  source           = "app.terraform.io/pab-cloud-infrastructure/kv/azure"
  version          = "2.0.2"
  bus_stack        = "pab-stack"
  env_stack        = "pab"
  loc_code         = "ne"
  region           = "North Europe"
  rg_name          = azurerm_resource_group.pab-pab-rg.name
  sku              = "standard"
  public_enabled   = true
  rbac_enabled     = true
  subnet_id        = azurerm_subnet.pab-pep-pab-snet.id
  pri_zone_kv      = local.dns_kvvc
  subnet_id_ops-ci = local.snet_cis
  kv_ips           = local.kv_ips
  resource_tags    = local.tags
}

#Create Key Vault Secret for VM admin login
resource "azurerm_key_vault_secret" "pabvm-admin-log-pab" {
  name         = "vm-pab-ogin"
  value        = "pabuser"
  key_vault_id = module.kv-pab-pab-stack.kv-id
  content_type = "Local VM admin login"
}

# Create VM password
resource "random_password" "pabvm-ran-pass-pab" {
  length      = 20
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  min_special = 1
  special     = true
}

#Create Key Vault Secret for VM password
resource "azurerm_key_vault_secret" "pabvm-admin-pass-pab" {
  name         = "vm-pab-password"
  value        = random_password.pabvm-ran-pass-pab.result
  key_vault_id = module.kv-pab-pab-stack.kv-id
  content_type = "Local VM admin password"
}
