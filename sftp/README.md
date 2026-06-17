# sftp

Terraform code for deploying and managing an Azure SFTP-enabled storage account for secure file transfer.

## Overview

This folder provisions an Azure Storage Account with SFTP enabled via Hierarchical Namespace (HNS), providing a secure, managed file transfer capability. The environment is deployed with private endpoints for blob and Data Lake (DFS) access, network access restrictions, and full diagnostic logging for audit and compliance purposes.

## Files

| File | Description |
|------|-------------|
| `sftp_np.tf` | Resource group, SFTP storage account (ZRS replication), private endpoints for blob and DFS, diagnostic logging |

## Architecture Decisions

### Why Azure Storage SFTP over a dedicated SFTP server?

A traditional VM-hosted SFTP server was considered but Azure Storage SFTP was chosen for the following reasons:

- **Managed service** — no VM to patch, maintain or monitor; Microsoft manages the underlying infrastructure
- **Hierarchical Namespace (HNS)** — enables Data Lake Storage Gen2 capabilities alongside SFTP, providing flexible access patterns for downstream data processing
- **Native private endpoint support** — blob and DFS endpoints can be placed behind private endpoints, keeping all traffic off the public internet
- **Cost effective** — no compute cost, pay only for storage consumed

### Replication Strategy

ZRS (Zone Redundant Storage) is used — resilient across availability zones within a region, providing high availability without the cost of cross-region replication.

### Network Access

The storage account uses `default_action = "Deny"` — all access is blocked by default. Access is permitted only from:
- Specific whitelisted IP ranges (defined in locals)
- Approved VNet subnets via service endpoints

Private endpoints are deployed for both `blob` and `dfs` subresources, enabling private access from within the VWAN-connected network.

### Diagnostic Logging

All storage read, write and delete operations are logged to a dedicated Log Analytics Workspace for audit and compliance. This provides a full activity trail of file transfers.

## What Is Not Included

The following supporting files are not included as they contain environment-specific references that cannot be meaningfully sanitised:

- `locals.tf` — local values including subnet IDs, DNS zone IDs, allowed IP ranges and Log Analytics Workspace references
- `variables.tf` — input variables including region
- `provider.tf` — Azure provider configuration including subscription IDs

These are standard Terraform constructs — in a real deployment they would reference your own subscription IDs, resource names and environment-specific values.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)
