# sa

A reusable Terraform module for deploying an Azure Storage Account with a blob private endpoint, configurable blob properties and consistent tagging.

## Overview

This module abstracts the common pattern of deploying a Storage Account with versioning, change feed, restore policy, blob retention and a private endpoint into a single reusable call. It is designed to be called multiple times across different environments and stacks with different configurations passed in via variables.

## Files

| File | Description |
|------|-------------|
| `main.tf` | Storage Account resource, blob private endpoint, mandatory tags merge and locals |
| `variables.tf` | All input variables — resource group, stack identifiers, region, account configuration, blob properties and networking |
| `outputs.tf` | Outputs for storage account name, ID, identity, access keys, connection strings and endpoints |

## Usage

```hcl
module "sa-example" {
  source  = "./modules/sa"

  bus_stack         = "app"
  env_stack         = "dev"
  loc_code          = "ne"
  rg_name           = azurerm_resource_group.example-rg.name
  region            = "North Europe"
  acc_kind          = "StorageV2"
  acc_tier          = "Standard"
  acc_rep_type      = "GRS"
  pub_net_acc       = "false"
  hns_enabled       = "false"
  nfs_enabled       = "false"
  sftp_enabled      = "false"
  ver_enabled       = "true"
  chan_feed_enabled  = "true"
  blob_ret_days     = 7
  con_ret_days      = 7
  restore_days      = 3
  subnet_id         = azurerm_subnet.example-pep-subnet.id
  pri_zone_sa_blob  = local.dns_sabc
  resource_tags     = local.tags
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
| `acc_kind` | Account kind — BlobStorage, BlockBlobStorage, FileStorage, Storage or StorageV2 | string | Yes |
| `acc_tier` | Account tier — Standard or Premium | string | Yes |
| `acc_rep_type` | Replication type — LRS, GRS, RAGRS, ZRS or RAGZRS | string | Yes |
| `pub_net_acc` | Enable public network access — true or false | string | Yes |
| `hns_enabled` | Enable Hierarchical Namespace (required for Data Lake Gen2 and SFTP) | string | Yes |
| `nfs_enabled` | Enable NFSv3 protocol | string | Yes |
| `sftp_enabled` | Enable SFTP | string | Yes |
| `ver_enabled` | Enable blob versioning | string | Yes |
| `chan_feed_enabled` | Enable change feed | string | Yes |
| `blob_ret_days` | Days to retain deleted blobs | string | Yes |
| `con_ret_days` | Days to retain deleted containers | string | Yes |
| `restore_days` | Days to keep restore points (must be less than blob_ret_days) | string | Yes |
| `subnet_id` | Subnet ID for the blob private endpoint | string | Yes |
| `pri_zone_sa_blob` | Private DNS Zone ID for blob storage | string | Yes |
| `resource_tags` | Resource tags map | map(string) | Yes |

## Outputs

| Output | Description |
|--------|-------------|
| `storage_account_name` | Name of the deployed storage account |
| `id` | Resource ID of the storage account |
| `identity` | Identity block with principal ID and tenant ID |
| `primary_access_key` | Primary access key |
| `secondary_access_key` | Secondary access key |
| `primary_connection_string` | Primary connection string |
| `secondary_connection_string` | Secondary connection string |
| `primary_blob_connection_string` | Primary blob connection string |
| `secondary_blob_connection_string` | Secondary blob connection string |
| `primary_blob_endpoint` | Primary blob endpoint URL |
| `secondary_blob_endpoint` | Secondary blob endpoint URL |
| `primary_file_endpoint` | Primary file endpoint URL |
| `secondary_file_endpoint` | Secondary file endpoint URL |

## Design Decisions

### Naming Convention

Storage account names are constructed from `bus_stack`, `env_stack` and `loc_code` with a company prefix — keeping names consistent, identifiable and within Azure's 24 character limit.

### Restore Policy

Versioning and change feed are both enabled by default to support the blob restore policy. `restore_days` must always be set lower than `blob_ret_days` — if they are equal or higher, Terraform will fail at apply time.

### Private Endpoint

A blob private endpoint is always deployed alongside the storage account, placed in the subnet provided via `subnet_id`. Public network access is controlled separately via `pub_net_acc` — for fully private deployments set this to `false`.

### Mandatory Tags

A `mandatory_tags` local merges `source = "terraform"` and `company = "pab"` into every storage account's tags alongside the caller-provided `resource_tags`, ensuring consistent tagging for cost management and governance.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

