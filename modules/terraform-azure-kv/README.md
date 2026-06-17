# kv

A reusable Terraform module for deploying an Azure Key Vault with a private endpoint, network ACLs, RBAC authorisation and consistent tagging.

## Overview

This module abstracts the common pattern of deploying a Key Vault with soft delete, private endpoint access, network access controls and RBAC into a single reusable call. It is designed to be called multiple times across different environments and stacks with different configurations passed in via variables.

## Files

| File | Description |
|------|-------------|
| `main.tf` | Key Vault resource, private endpoint, network ACLs, mandatory tags merge and locals |
| `variables.tf` | All input variables — resource group, stack identifiers, region, SKU, networking, access controls and tags |
| `outputs.tf` | Outputs for Key Vault ID and vault URI |

## Usage

```hcl
module "kv-example" {
  source           = "./modules/kv"
  bus_stack        = "app"
  env_stack        = "dev"
  loc_code         = "ne"
  region           = "North Europe"
  rg_name          = azurerm_resource_group.example-rg.name
  sku              = "standard"
  public_enabled   = true
  rbac_enabled     = true
  subnet_id        = azurerm_subnet.example-pep-subnet.id
  pri_zone_kv      = local.dns_kvvc
  subnet_id_ops-ci = local.snet_cis
  kv_ips           = local.kv_ips
  resource_tags    = local.tags
}
```

## Inputs

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `bus_stack` | Business unit identifier (e.g. app, ops) | string | Yes |
| `env_stack` | Environment stack (e.g. dev, uq, qual, pab, prod, dr) | string | Yes |
| `loc_code` | Abbreviated location code (e.g. ne, we) | string | Yes |
| `region` | Azure region | string | Yes |
| `rg_name` | Resource group name | string | Yes |
| `sku` | Key Vault SKU — standard or premium | string | Yes |
| `public_enabled` | Enable public network access — true or false | bool | Yes |
| `rbac_enabled` | Enable RBAC authorisation — true or false | bool | Yes |
| `subnet_id` | Subnet ID for the private endpoint | string | Yes |
| `pri_zone_kv` | Private DNS Zone ID for Key Vault | string | Yes |
| `subnet_id_ops-ci` | Container instance subnet ID on Operations VNet — added to network ACL allowed subnets | string | Yes |
| `kv_ips` | List of IP addresses allowed through the network ACL | list(string) | Yes |
| `resource_tags` | Resource tags map | map(string) | Yes |

## Outputs

| Output | Description |
|--------|-------------|
| `kv-id` | Resource ID of the Key Vault |
| `vault_uri` | URI of the Key Vault |

## Design Decisions

### Naming Convention

Key Vault names are constructed from `bus_stack`, `env_stack` and `loc_code` — keeping names consistent and identifiable across environments and stacks.

### Network ACLs

`default_action = "Deny"` blocks all access by default. Access is permitted only from:
- IP addresses specified in `kv_ips` (e.g. trusted management IPs)
- The Operations container instance subnet via `subnet_id_ops-ci`
- `bypass = "AzureServices"` allows trusted Azure services to access the vault without explicit rules

### Private Endpoint

A private endpoint is always deployed alongside the Key Vault, ensuring access from within the VWAN-connected network without traversing the public internet.

### RBAC Authorisation

`rbac_authorization_enabled` is configurable — when `true`, access to secrets, keys and certificates is controlled via Azure RBAC role assignments rather than legacy access policies. This is the recommended approach for new deployments.

### Soft Delete

Soft delete is enabled with a 30-day retention period. `purge_protection_enabled = false` allows vaults and secrets to be permanently deleted during development and testing — this should be reviewed for production deployments where purge protection may be required for compliance.

### Mandatory Tags

A `mandatory_tags` local merges `source = "terraform"` and `company = "pab"` into every Key Vault's tags alongside the caller-provided `resource_tags`, ensuring consistent tagging for cost management and governance.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)


