# acr

Terraform code for deploying and managing a private Azure Container Registry (ACR) with geo-replication, private endpoint access and granular RBAC assignments.

## Overview

This folder provisions a Premium tier Azure Container Registry with public network access disabled, accessible only via private endpoint within the VWAN-connected network. Role assignments are configured for AKS clusters, engineering teams and build agent scale sets, providing fine-grained pull and push permissions.

## Files

| File | Description |
|------|-------------|
| `main.tf` | ACR resource group, container registry, private endpoint, DNS zone group and all RBAC role assignments |

## Architecture Decisions

### Why Premium SKU?

Premium is required for:
- **Private endpoints** — only supported on Premium tier
- **Geo-replication** — registry replicated to West Europe for low-latency image pulls from workloads running in that region
- **Network rule sets** — `default_action = "Deny"` with no IP rules, ensuring all access goes via private endpoint only

### Private by Default

`public_network_access_enabled = false` and `network_rule_set.default_action = "Deny"` means the registry is completely inaccessible from the public internet. All image pulls and pushes must originate from within the VWAN-connected private network.

`network_rule_bypass_option = "AzureServices"` is set to allow trusted Azure services (e.g. Azure DevOps, AKS) to access the registry without traversing the firewall.

### Geo-Replication

A replica is deployed in West Europe with `regional_endpoint_enabled = true`, providing a regional endpoint for workloads in that region to pull images without cross-region latency.

### RBAC Assignments

Access is granted using least-privilege role assignments rather than admin credentials:

| Principal | Role | Purpose |
|-----------|------|---------|
| AKS clusters | AcrPull | Pull images for workload deployments |
| Engineering group | AcrPull | Pull images for local development |
| Windows VMSS | AcrPull + AcrPush | Build agents pull base images and push build artifacts |
| Linux VMSS | AcrPull + AcrPush | Build agents pull base images and push build artifacts |

Admin access is disabled (`anonymous_pull_enabled = false`) — all access is identity-based.

## What Is Not Included

The following supporting files are not included as they contain environment-specific references that cannot be meaningfully sanitised:

- `locals.tf` — local values including subnet IDs, DNS zone IDs, AKS cluster IDs, engineering group IDs and VMSS managed identity IDs
- `variables.tf` — input variables including region
- `provider.tf` — Azure provider configuration including subscription IDs

These are standard Terraform constructs — in a real deployment they would reference your own subscription IDs, resource names and environment-specific values.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

