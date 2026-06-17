###############################################################
#                     DNS Virtual Machines                    #
###############################################################

# created using the vm module
module "vmdnsne" {
  source        = "app.terraform.io/pab-cloud-infrastructure/vm/azure"
  version       = "2.0.5"
  rg_name       = azurerm_resource_group.dns-ops-rg.name
  vmname        = "dns"
  region        = "North Europe"
  location_code = "ne"
  vm_size       = "Standard_B2ls_v2"
  osdisk_type   = "Standard_LRS"
  publisher     = "MicrosoftWindowsServer"
  offer         = "WindowsServer"
  sku           = "2022-datacenter-azure-edition"
  timezone      = "GMT Standard Time"
  subnet_id     = azurerm_subnet.ops-vm-subnet.id
  # sanitised
  static_ip_address = "0.0.0.0"
  # created and stored in a key vault, how that secret is set up can be found in kv.tf
  vm_adminuser  = azurerm_key_vault_secret.dns-admin-log.value
  vm_adminpass  = azurerm_key_vault_secret.dns-admin-pass.value
  lic_type      = "Windows_Server"
  resource_tags = local.tags
}

# Enable AADLogin Extension for vmdnsne
resource "azurerm_virtual_machine_extension" "vmdns-aad-ext" {
  name                       = "AADLogin"
  virtual_machine_id         = module.vmdnsne.vm-id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = false

  depends_on = [
    module.vmdnsne
  ]
}


# Create a record in private dns zone pabcompany.internal for vmdnsne
resource "azurerm_private_dns_a_record" "vmdnsne-dns" {
  #  provider = azurerm.ops
  name                = module.vmdnsne.vm-name
  zone_name           = azurerm_private_dns_zone.pri-zone-pabcompany.name
  resource_group_name = azurerm_resource_group.dns-ops-rg.name
  ttl                 = 300
  records             = [module.vmdnsne.vm-ip]

  depends_on = [
    module.vmdnsne
  ]
}
