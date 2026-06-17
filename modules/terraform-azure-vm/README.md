# vm

A reusable Terraform module for deploying a Windows Virtual Machine in Azure, with a static IP network interface, system-assigned managed identity, automatic patching and configurable image reference.

## Overview

This module abstracts the common pattern of deploying a Windows VM with a NIC, static private IP, OS disk and identity into a single reusable call. It is designed to be called multiple times across different environments and stacks with different configurations passed in via variables.

## Files

| File | Description |
|------|-------------|
| `main.tf` | Network interface, Windows Virtual Machine resource, mandatory tags merge and locals |
| `variables.tf` | All input variables — resource group, VM name, environment, region, size, OS image, networking, credentials and tags |
| `outputs.tf` | Outputs for VM name, VM ID, private IP address and identity block |

## Usage

```hcl
module "vm-example" {
  source            = "./modules/vm"
  rg_name           = azurerm_resource_group.example-rg.name
  vmname            = "example"
  env               = "dev"
  region            = "North Europe"
  location_code     = "ne"
  vm_size           = "Standard_B2ls_v2"
  osdisk_type       = "Standard_LRS"
  publisher         = "MicrosoftWindowsServer"
  offer             = "WindowsServer"
  sku               = "2022-datacenter-azure-edition"
  timezone          = "GMT Standard Time"
  subnet_id         = azurerm_subnet.example-subnet.id
  static_ip_address = "0.0.0.0"
  vm_adminuser      = "adminuser"
  vm_adminpass      = "password"
  lic_type          = "Windows_Server"
  resource_tags     = local.tags
}
```

## Inputs

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `rg_name` | Resource group name | string | Yes |
| `vmname` | Name of the virtual machine | string | Yes |
| `env` | Environment stack (dev, uq, qual, pab, prod, dr) — omit for ops VMs | string | No (default: null) |
| `region` | Azure region | string | Yes |
| `location_code` | Shorthand region code (e.g. ne, we) | string | Yes |
| `vm_size` | Azure VM size | string | Yes |
| `osdisk_type` | OS disk storage account type | string | Yes |
| `publisher` | OS image publisher | string | Yes |
| `offer` | OS image offer | string | Yes |
| `sku` | OS image SKU | string | Yes |
| `timezone` | VM timezone | string | Yes |
| `subnet_id` | Subnet ID for the NIC | string | Yes |
| `static_ip_address` | Static private IP address | string | Yes |
| `vm_adminuser` | Local admin username | string | Yes |
| `vm_adminpass` | Local admin password | string | Yes |
| `lic_type` | Licence type — Windows_Server for Hybrid Benefit, None otherwise | string | Yes |
| `resource_tags` | Resource tags map | map(string) | Yes |

## Outputs

| Output | Description |
|--------|-------------|
| `vm-name` | Name of the deployed VM |
| `vm-id` | Resource ID of the VM |
| `vm-ip` | Private IP address from the NIC |
| `vm-identity` | Identity block containing principal ID and tenant ID |

## Design Decisions

### Naming Convention

VM and NIC names are dynamically constructed from `vmname`, `env` and `location_code`. When `env` is set to `null` (the default), the environment segment is omitted — useful for operations VMs that are not tied to a specific environment stack.

### Automatic Patching

`patch_mode` and `patch_assessment_mode` are both set to `AutomaticByPlatform` with `bypass_platform_safety_checks_on_user_schedule_enabled = true`. This integrates with Azure Update Manager, allowing patching schedules to be managed centrally rather than per VM.

### System-Assigned Managed Identity

All VMs are deployed with a system-assigned managed identity. This enables the VM to authenticate to Azure services (e.g. Key Vault, Storage) without storing credentials, using RBAC assignments to control access.

### Mandatory Tags

A `mandatory_tags` local merges `source = "terraform"` and `company = "pab"` into every VM's tags alongside the caller-provided `resource_tags`. This ensures consistent tagging for cost management and governance across all VMs deployed via this module.

### Hybrid Benefit

`lic_type` accepts `Windows_Server` to apply Azure Hybrid Benefit for VMs covered by existing Windows Server licences, reducing compute cost. Set to `None` for VMs not covered.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

