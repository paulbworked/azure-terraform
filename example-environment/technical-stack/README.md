# example-environment

A sanitised, real-world example of a complete Azure environment stack — demonstrating how Technical and Environment stacks are structured, deployed and connected within a private VWAN-based architecture.

## Overview

This folder represents a single environment within a multi-environment Azure deployment. It is provided as a reference architecture showing how all components fit together — networking, compute, storage, AKS, Key Vault, backup and monitoring — deployed consistently across environments using Terraform modules.

## Architecture Overview

A **Technical Stack** is any shared infrastructure used by the main environment, such as a virtual network, virtual machines, AKS clusters, generic storage accounts and key vaults — each with their associated private endpoints.

An **Environment Stack** is anything within an individual application environment, such as a Postgres instance, Service Bus Namespaces, Queues and Topics, a MongoDB cluster, storage accounts and key vaults — each with their associated private endpoints.

## Files

| File | Description |
|------|-------------|
| `pab_stack.tf` | Resource group for the environment stack |
| `vnets.tf` | Virtual Network, subnets (AKS, VM, PEP, PostgreSQL), VWAN hub connection and all Private DNS Zone links |
| `aks.tf` | AKS cluster deployed via reusable module with node pool configuration, maintenance windows and network policy (Cilium) |
| `virtualmachines.tf` | Windows VM with managed data disk, AAD Login extension, custom script extension and DNS A record |
| `kv.tf` | Key Vault for the technical stack, VM credentials generated via random_password and stored as secrets |
| `storage.tf` | Generic storage account and reporting services storage account, both via reusable module with private endpoints |
| `xdrive.tf` | Shared file storage account (xdrive) with blob and file private endpoints, file share and diagnostic logging |
| `rsv.tf` | Recovery Services Vault with private endpoint, VM backup policies (daily and weekly) and file share backup |
| `networkwatcher.tf` | Network Watcher for the environment |

## Architecture Decisions

### Environment Isolation

Each environment runs in its own Virtual Network, connected to the central VWAN hub. This provides:
- Full network isolation between environments
- Centralised firewall inspection of all traffic via the VWAN secured hub
- Consistent private DNS resolution across all environments via shared Private DNS Zones linked to each VNet

### Subnet Design

| Subnet | Purpose |
|--------|---------|
| `snet-aks` | AKS node pools |
| `snet-vm` | Virtual machines |
| `snet-pep` | Private endpoints for all services |
| `snet-psql` | PostgreSQL flexible server (delegated subnet) |

All subnets have `default_outbound_access_enabled = false` — no implicit internet egress.

### AKS Configuration

- Private cluster with private DNS zone — API server not publicly accessible
- Cilium network policy and data plane for advanced network security and observability
- Overlay network mode for efficient IP address utilisation
- Maintenance windows configured per environment to stagger updates and avoid simultaneous cluster upgrades
- Additional node pool available for resource-intensive workloads with node taints to control scheduling

### Key Vault & Secrets

VM credentials are generated at apply time via `random_password` and stored directly into Key Vault. No credentials are hardcoded in code or state files.

### Backup Strategy

| Resource | Policy | Frequency |
|----------|--------|-----------|
| Virtual Machine | Weekly | Sunday 23:00, 10 weekly retain |
| Virtual Machine | Daily | Daily 23:00, 10 daily retain |
| File Share (xdrive) | Daily | Daily 23:00, 90 daily retain |

The Recovery Services Vault is deployed with `public_network_access_enabled = false` — all backup traffic via private endpoint.

### Storage Accounts

Three storage accounts are provisioned per environment:
- **Generic stack storage** — general purpose, versioning and restore policy enabled
- **Reporting services storage** — dedicated containers for reporting workloads
- **xdrive** — shared file storage mapped as a network drive within the environment, with both blob and file private endpoints

## What Is Not Included

The following supporting files are not included as they contain environment-specific references that cannot be meaningfully sanitised:

- `locals.tf` — local values including VNet IDs, DNS zone IDs, Key Vault IDs, AKS IDs and environment-specific references
- `variables.tf` — input variables including region and environment flags
- `outputs.tf` — output values for resource IDs
- `provider.tf` — Azure provider configuration including subscription IDs

These are standard Terraform constructs — in a real deployment they would reference your own subscription IDs, resource names and environment-specific values.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

