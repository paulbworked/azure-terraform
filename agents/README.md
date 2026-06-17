# agents

Terraform code for deploying and managing Azure DevOps self-hosted build agent infrastructure, including Windows and Linux Virtual Machine Scale Sets and a dedicated performance testing VM.

## Overview

This folder provisions the compute infrastructure used to run Azure DevOps pipelines privately within the VWAN-connected network. All agents run on custom images built with the required tooling pre-installed, eliminating dependency on Microsoft-hosted agents and ensuring all pipeline traffic stays within the private network boundary.

## Files

| File | Description |
|------|-------------|
| `vmss.tf` | Windows Build Agent VMSS, Linux Build Agent VMSS, Cypress Test Agent VMSS — all using custom images from a Shared Image Gallery |
| `vnets.tf` | Agents Virtual Network, agent subnet, VWAN hub connection and Private DNS Zone links for all Azure services |
| `vm.tf` | Dedicated Cypress performance testing VM with static IP, system-assigned identity and Virtual Machine Contributor role assignment |
| `cloud-init.yaml` | Cloud-init configuration for Linux agents — installs browser dependencies (Chrome, Firefox), xvfb for headless testing, .NET SDK 8.0 and Git |

## Architecture Decisions

### Why self-hosted agents over Microsoft-hosted?

Microsoft-hosted agents run outside the private network and cannot reach resources protected by private endpoints. Since all infrastructure is deployed privately by default (no public endpoints), self-hosted agents running inside the VWAN-connected network are required for pipelines to access Azure resources during deployment and testing.

### Virtual Machine Scale Sets over static VMs

VMSS is used rather than individual VMs for the following reasons:

- **Elastic scaling** — Azure DevOps manages instance count based on pipeline demand; idle agents scale down, busy queues scale up
- **Consistent state** — each agent starts from a known, clean image rather than accumulating state over time
- **Cost efficient** — instances are only running when pipelines are active
- `overprovision = false` is set to prevent Azure from spinning up extra instances during scaling events, which would cause pipeline registration issues with Azure DevOps

### Custom Images via Shared Image Gallery

All VMSS and VM resources reference custom images stored in a Shared Image Gallery rather than using base OS images. This ensures:

- Required tooling (Azure DevOps agent, SDKs, browsers, test frameworks) is pre-installed
- Faster agent startup — no cloud-init provisioning delay at scale
- Consistent, versioned images across all agent pools

### Three Agent Pools

| Scale Set | OS | Purpose |
|-----------|-----|---------|
| Windows Build Agent | Windows Server 2025 | .NET builds, Windows-specific pipelines |
| Linux Build Agent | Ubuntu 24.04 | General build and deployment pipelines |
| Cypress Agent | Ubuntu 24.04 | End-to-end browser testing via Cypress |

A dedicated Cypress performance VM is also provisioned for longer-running performance test suites that require a persistent environment rather than ephemeral scale set instances.

### Lifecycle Ignore Rules

All VMSS resources include `ignore_changes` for `tags`, `instances` and `extension`. This is intentional:

- Azure DevOps dynamically modifies tags and instance counts as it manages the agent pool
- Azure DevOps installs its own pipeline extension onto the scale set — Terraform should not attempt to remove it on subsequent applies

## What Is Not Included

The following supporting files are not included as they contain environment-specific references that cannot be meaningfully sanitised:

- `locals.tf` — local values including VWAN hub ID, DNS zone names, managed identity IDs and VMSS passwords sourced from Key Vault
- `variables.tf` — input variables including region
- `provider.tf` — Azure provider configuration including subscription IDs

These are standard Terraform constructs — in a real deployment they would reference your own subscription IDs, resource names and environment-specific values.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

