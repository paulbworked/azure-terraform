# operations

Terraform code for centralised operational infrastructure in Azure, providing the shared services foundation that all environments depend on.

## Overview

This folder contains the core operational stack — the resources that support, monitor and protect the wider Azure environment. Everything here is built private by default, with secrets managed centrally via Key Vault, backups handled by Recovery Services Vault, and alerting configured across all critical infrastructure components.

## Files

| File | Description |
|------|-------------|
| `operations.tf` | Operations resource group and Log Analytics Workspace for storage account auditing |
| `vnets.tf` | Operations Virtual Network, subnets (VM, PEP, NM, CI, DG, web apps, AKS) and all Private DNS Zone links to the Operations VNet |
| `kv.tf` | Key Vault deployments via reusable module, VM admin credentials generated via random_password and stored as Key Vault Secrets |
| `virtualmachines.tf` | DNS Virtual Machine, deployed via reusable module with AAD Login extension and Private DNS A records |
| `rsv.tf` | Recovery Services Vault with private endpoint, VM backup policy (weekly), storage account backup policy (daily) and backup registrations |
| `alerts.tf` | Azure Monitor action group, Service Health alerts (incident, advisory, security, maintenance) |

## Architecture Decisions

### Centralised Operations VNet

A dedicated Operations VNet is used rather than distributing operational resources across environment stacks. This provides a single, trusted network boundary for shared services — DNS, Key Vault, monitoring, backup — that all other VNets connect to via the VWAN hub. It simplifies access control and reduces the attack surface.

### Subnet Segmentation

The Operations VNet is divided into purpose-specific subnets:

| Subnet | Purpose |
|--------|---------|
| `snet-nm` | Network management devices |
| `snet-vm` | Virtual machines (DNS) |
| `snet-pep` | Private endpoints for all services |
| `snet-ci` | Container instances |
| `snet-dg` | Fabric Data Gateway |
| `snet-wapp` | Web applications |
| `snet-aks` | AKS workloads |

All subnets have `default_outbound_access_enabled = false` — no implicit internet egress.

### Key Vault & Secret Management

VM admin credentials are never hardcoded. Passwords are generated at apply time using `random_password` and stored directly into Key Vault as secrets. VMs reference these secrets at provisioning time, ensuring credentials are never exposed in state files or code.

### Recovery Services Vault

The RSV is deployed with `public_network_access_enabled = false` and accessed only via private endpoint. This ensures backup traffic never traverses the public internet.

### Alerting Strategy

Alerts are configured at four levels:
- **Service Health** — Azure platform incidents, advisories, security and maintenance events
- **Administrative changes** — any write or delete operations against critical network resources (VWAN, Hub, Firewall, VPN)
- **Resource Health** — availability and health state of VWAN Hub, P2S VPN Gateway and Azure Firewall
- **Metric alerts** — SNAT port exhaustion, firewall throughput overutilisation and firewall health state

## What Is Not Included

The following supporting files are not included as they contain environment-specific references that cannot be meaningfully sanitised:

- `locals.tf` — local values, data source references, IP group IDs, DNS zone IDs and environment-specific values
- `variables.tf` — input variables including region, tenant ID and environment flags
- `outputs.tf` — output values for resource IDs and connection details
- `provider.tf` — Azure provider configuration including subscription IDs

These are standard Terraform constructs — in a real deployment they would reference your own subscription IDs, tenant ID, resource names and environment-specific values.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

