module "vmpabne" {
  source        = "app.terraform.io/pab-cloud-infrastructure/vm/azure"
  version       = "2.0.5"
  rg_name       = azurerm_resource_group.pab-pab-rg.name
  vmname        = "pab"
  env           = "pab"
  region        = "North Europe"
  location_code = "ne"
  vm_size       = "Standard_E8s_v4"
  osdisk_type   = "Standard_LRS"
  publisher     = "MicrosoftWindowsServer"
  offer         = "WindowsServer"
  sku           = "2022-datacenter-azure-edition"
  timezone      = "GMT Standard Time"
  subnet_id     = azurerm_subnet.pab-vm-pab-snet.id
  # sanitised
  static_ip_address = "0.0.0.0"
  vm_adminuser      = azurerm_key_vault_secret.pabvm-admin-log-pab.pabue
  vm_adminpass      = azurerm_key_vault_secret.pabvm-admin-pass-pab.pabue
  lic_type          = "Windows_Server"
  resource_tags     = local.tags
}

resource "azurerm_managed_disk" "vmpabpabne-disk1" {
  name                          = "${module.vmpabne.vm-name}-disk1"
  resource_group_name           = azurerm_resource_group.pab-pab-rg.name
  location                      = var.region_ne
  storage_account_type          = "Standard_LRS"
  zone                          = "2"
  create_option                 = "Empty"
  disk_size_gb                  = "512"
  network_access_policy         = "DenyAll"
  public_network_access_enabled = false
  tags                          = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vmpabne-disk1-attach" {
  managed_disk_id    = azurerm_managed_disk.vmpabne-disk1.id
  virtual_machine_id = module.vmpabne.vm-id
  lun                = "0"
  caching            = "ReadWrite"
}

# Enable AADLogin Extension for vmpabpabne
resource "azurerm_virtual_machine_extension" "vmpabne-aad-ext" {
  name                       = "AADLogin"
  virtual_machine_id         = module.vmpabne.vm-id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = false

  depends_on = [
    module.vmpabne
  ]
}

# Create a record in private dns zone pabcompany.internal
resource "azurerm_private_dns_a_record" "vmpabpabne-dns" {
  provider            = azurerm.ops
  name                = module.vmpabpabne.vm-name
  zone_name           = local.dns_tri_n
  resource_group_name = local.rg_dns
  ttl                 = 300
  records             = [module.vmpabpabne.vm-ip]
}

# Assign Storage Blob Data Reader role to VM
resource "azurerm_role_assignment" "vmpabpabne-saBlobDR" {
  scope              = local.sa_ops
  role_definition_id = local.rbac_saBlobDR
  principal_id       = module.vmpabpabne.vm-identity[0].principal_id

  lifecycle {
    ignore_changes = [role_definition_id, principal_id, ]
  }
}

resource "azurerm_virtual_machine_extension" "vmpabpabne-vminstall" {
  name                       = "vminstallscript"
  virtual_machine_id         = module.vmpabpabne.vm-id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true

  depends_on = [
    azurerm_role_assignment.vmpabpabne-saBlobDR
  ]

  protected_settings = <<SETTINGS

  {
     "fileUris": ["https://pabopsprodnesa.blob.core.windows.net/vmscripts/vm_install.ps1"],
     "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File vm_install.ps1",
     "managedIdentity" : {}

  }
  SETTINGS

}

# The virtual machine is automatically added to the Windows Update service through the use of tagging, see the Confluence documentation for more information
