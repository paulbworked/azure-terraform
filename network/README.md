# network

Terraform code for Azure networking infrastructure, forming the core of a secure, private-by-default cloud environment.

## Overview

This folder contains the networking foundation of the Azure environment. All resources are built around a Virtual WAN (VWAN) architecture with a secured hub, ensuring all traffic — both internal and internet-bound — is routed through Azure Firewall. No resources are publicly exposed.

## Files

| File | Description |
|------|-------------|
| `vwan.tf` | Azure Virtual WAN, secured hub, Azure Firewall, Firewall Policy, P2S and S2S VPN Gateways, routing intent and diagnostic logging |
| `dns.tf` | Private DNS Zones for all Azure services including Key Vault, Storage, AKS, PostgreSQL, Service Bus, ACR, App Services and a custom internal zone |
| `networkwatcher.tf` | Network Watcher and associated Log Analytics Workspace for network flow log capture |

## Architecture Decisions

### Why Virtual WAN over traditional hub and spoke?

A traditional hub and spoke topology with a central NVA or Azure Firewall was considered, but Virtual WAN was chosen for the following reasons:

- **Managed routing** — Microsoft manages the underlying routing infrastructure, eliminating the need to manually maintain User Defined Routes (UDRs) across every spoke
- **Built-in VPN support** — P2S and S2S VPN gateways are integrated natively into the hub, simplifying remote access and site-to-site connectivity
- **Scalability** — new spoke VNets can be connected without hitting peering limits or managing complex routing tables
- **Secured hub** — Azure Firewall integrates directly as a secured hub, with routing intent enforcing that all private and internet traffic transits the firewall

### Private DNS

A centralised Private DNS Zone approach is used rather than per-resource or per-environment DNS. All zones are linked to a shared Operations VNet, providing consistent name resolution across all environments without DNS leakage to the public internet.

### Firewall Policy

Threat intelligence mode is set to `Deny`, blocking known malicious IPs and domains at the firewall level without requiring explicit rules.

## What Is Not Included

The following supporting files are not included in this repository as they contain environment-specific references, resource names and data source lookups that are tightly coupled to the specific deployment and cannot be meaningfully sanitised without losing context:

- `locals.tf` — local values, data source references, IP group IDs, DNS zone IDs and environment-specific CIDR ranges
- `variables.tf` — input variables including region, tenant ID and environment flags
- `outputs.tf` — output values for resource IDs and connection details
- `provider.tf` — Azure provider configuration including subscription IDs

These files are standard Terraform constructs. In a real deployment they would reference your own subscription IDs, tenant ID, resource names and environment-specific values.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

