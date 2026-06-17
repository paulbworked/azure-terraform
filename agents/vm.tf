###############################################################
#                 Cypress Performance VM                      #
# This VM uses a specialised image that needs to be attached  #
# to a disk.                                                  #
###############################################################

# Create Windows Network Interface
resource "azurerm_network_interface" "vm-pabwin-nic" {
  name                = "vmcyp-nic"
  location            = var.region_ne
  resource_group_name = azurerm_resource_group.agents-rg.name

  ip_configuration {
    name                          = "nic01"
    subnet_id                     = azurerm_subnet.ag-subnet.id
    private_ip_address_allocation = "Static"
    # sanitised
    private_ip_address = "0.0.0.0"
  }
}

# Create Windows Virtual Machine
resource "azurerm_virtual_machine" "vm-pabwin" {
  location              = var.region_ne
  name                  = "vmcyp"
  network_interface_ids = [azurerm_network_interface.vm-pabwin-nic.id]
  resource_group_name   = azurerm_resource_group.agents-rg.name
  vm_size               = "Standard_D4ls_v5"
  zones                 = ["1"]

  boot_diagnostics {
    enabled     = true
    storage_uri = ""
  }

  identity {
    identity_ids = []
    type         = "SystemAssigned"
  }

  # sanitised
  storage_image_reference {
    id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-images-ops/providers/Microsoft.Compute/galleries//////"
    offer     = ""
    publisher = ""
    sku       = ""
    version   = ""
  }

  storage_os_disk {
    caching                   = "ReadWrite"
    create_option             = "FromImage"
    disk_size_gb              = 127
    image_uri                 = ""
    managed_disk_type         = "StandardSSD_LRS"
    name                      = "vmcyp_OSDISK"
    os_type                   = "Windows"
    write_accelerator_enabled = false
  }

  lifecycle {
    ignore_changes = []
  }

  tags = local.tags
}

# Assign Linux VMSS Virtual Machine Contributor permission
resource "azurerm_role_assignment" "vm-role-cont" {
  scope                = azurerm_virtual_machine.vm-pabwin.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = local.mi_vmss_lin
}
