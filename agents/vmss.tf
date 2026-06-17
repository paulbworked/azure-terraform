# Create resource group
resource "azurerm_resource_group" "agents-rg" {
  name     = "rg-agents"
  location = var.region_ne

  tags = local.tags

}

###############################################################
#                 Windows Build Agent Scale Set               #
###############################################################

# Create Windows Build Agent Scale Set
resource "azurerm_windows_virtual_machine_scale_set" "vmss-pabwin-vmssobawne" {
  name                        = "vmssobawne"
  resource_group_name         = azurerm_resource_group.agents-rg.name
  location                    = var.region_ne
  sku                         = "Standard_B4s_v2"
  instances                   = 4
  admin_username              = "pabuser"
  admin_password              = local.vmssobawne_pw
  computer_name_prefix        = "vmssobaw"
  license_type                = "Windows_Server"
  timezone                    = "GMT Standard Time"
  priority                    = "Regular"
  platform_fault_domain_count = "1"
  overprovision               = false
  single_placement_group      = false
  secure_boot_enabled         = true
  # sanitised
  source_image_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-images-ops/providers/Microsoft.Compute/galleries//////"
  enable_automatic_updates = false

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 128
  }

  network_interface {
    name    = "vmssobawne-nic"
    primary = true

    ip_configuration {
      name      = "nic01"
      primary   = true
      subnet_id = azurerm_subnet.ag-subnet.id
    }
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = local.vmss_ua_ids
    # identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-stack-uq/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-pab-ado-sc-uq"]
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags, instances, extension, ]
    # ignoring as azuredevops agent pool adds and changes tags
    # ignoring instances run
    # ignoring extensions for now as azure devops adds the pipeline and terraform tries to remove it
  }

}

###############################################################
#                 Linux Build Agent Scale Set                 #
###############################################################

# Create Linux Build Agent Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "vmss-pablin-vmssobalne" {
  name                            = "vmssobalne"
  resource_group_name             = azurerm_resource_group.agents-rg.name
  location                        = var.region_ne
  sku                             = "Standard_B4as_v2"
  instances                       = 2
  admin_username                  = "pabuser"
  admin_password                  = local.vmssobalne_pw
  disable_password_authentication = false
  computer_name_prefix            = "vmssobal"
  priority                        = "Regular"
  platform_fault_domain_count     = "1"
  overprovision                   = false
  single_placement_group          = false
  secure_boot_enabled             = true
  source_image_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-images-ops/providers/Microsoft.Compute/galleries////////"

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 64
  }

  network_interface {
    name    = "vmssobalne-nic"
    primary = true

    ip_configuration {
      name      = "nic01"
      primary   = true
      subnet_id = azurerm_subnet.ag-subnet.id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags, instances, extension, admin_password]
    # ignoring as azuredevops agent pool adds and changes tags
    # ignoring instances run
    # ignoring extensions for now as azure devops adds the pipeline and terraform tries to remove it
  }

}

###############################################################
#                 Cypress Agent Scale Set                     #
###############################################################

# Create Linux Build Agent Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "vmss-pablin-vmsscypne" {
  name                            = "vmsscypne"
  resource_group_name             = azurerm_resource_group.agents-rg.name
  location                        = var.region_ne
  sku                             = "Standard_D8as_v5"
  instances                       = 1
  admin_username                  = "pabuser"
  admin_password                  = local.vmsscypne_pw
  disable_password_authentication = false
  computer_name_prefix            = "vmsscyp"
  priority                        = "Regular"
  platform_fault_domain_count     = "1"
  overprovision                   = false
  single_placement_group          = false
  secure_boot_enabled             = true
  source_image_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-images-ops/providers/Microsoft.Compute/galleries///////"

  #custom_data = filebase64("${path.module}/cloud-init.yaml")

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmsscypne-nic"
    primary = true

    ip_configuration {
      name      = "nic01"
      primary   = true
      subnet_id = azurerm_subnet.ag-subnet.id
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags, instances, extension, ]
    # ignoring as azuredevops agent pool adds and changes tags
    # ignoring instances run
    # ignoring extensions for now as azure devops adds the pipeline and terraform tries to remove it
  }

}
