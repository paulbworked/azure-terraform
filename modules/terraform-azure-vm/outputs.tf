output "vm-name" {
    value = azurerm_windows_virtual_machine.vm.name
    description = "outputs the name of the vm"
}

output "vm-id" {
    value = azurerm_windows_virtual_machine.vm.id
    description = "outputs the id of the vm"
}

output "vm-ip" {
    value = azurerm_network_interface.vm-nic.private_ip_address
    description = "outputs the ip of the vm from the nic"
}

output "vm-identity"{
    value = azurerm_windows_virtual_machine.vm.identity
    description = "outputs the identity block with principal ID and tenant ID"
}