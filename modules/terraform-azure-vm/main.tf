locals {
  mandatory_tags = {
    source  = "terraform"
    company = "pab"
    update  = "windows"
  }
  applied_tags = merge(var.resource_tags, local.mandatory_tags)
}


# Create Windows Network Interface
resource "azurerm_network_interface" "vm-nic" {
  name                = var.env == "null" ? "vm${var.vmname}${var.location_code}-nic" : "vm${var.vmname}${var.env}${var.location_code}-nic"
  location            = var.region
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "nic01"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.static_ip_address

  }

  tags = local.applied_tags
}

# Create Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                                                   = var.env == "null" ? "vm${var.vmname}${var.location_code}" : "vm${var.vmname}${var.env}${var.location_code}"
  resource_group_name                                    = var.rg_name
  location                                               = var.region
  size                                                   = var.vm_size
  timezone                                               = var.timezone
  admin_username                                         = var.vm_adminuser
  admin_password                                         = var.vm_adminpass
  network_interface_ids                                  = [azurerm_network_interface.vm-nic.id]
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  patch_assessment_mode                                  = "AutomaticByPlatform"
  patch_mode                                             = "AutomaticByPlatform"
  os_disk {
    name                 = var.env == "null" ? "vm${var.vmname}${var.location_code}_OSDISK" : "vm${var.vmname}${var.env}${var.location_code}_OSDISK"
    caching              = "ReadWrite"
    storage_account_type = var.osdisk_type
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }

  license_type = var.lic_type

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = []
  }

  tags = local.applied_tags
}
