# aks

A reusable Terraform module for deploying a private Azure Kubernetes Service (AKS) cluster with a user-assigned managed identity, RBAC, Cilium network policy, Key Vault secrets provider and configurable maintenance windows.

## Overview

This module abstracts the common pattern of deploying a production-grade AKS cluster into a single reusable call. It creates a dedicated resource group, user-assigned managed identity with the required role assignments, and a fully configured private AKS cluster with node pool, network profile and maintenance window. It is designed to be called multiple times across different environments with different configurations passed in via variables.

## Files

| File | Description |
|------|-------------|
| `main.tf` | Resource group, user-assigned managed identity, role assignments (Private DNS Zone Contributor, Network Contributor, AcrPull), AKS cluster with node pool, network profile and maintenance window |
| `variables.tf` | All input variables — stack identifiers, region, cluster configuration, node pool settings, network profile, maintenance window and tags |
| `outputs.tf` | Outputs for cluster ID, FQDN, private FQDN, portal FQDN, identity, node resource group, kubelet identity and kube config |

## Usage

```hcl
module "aks-example" {
  source                 = "./modules/aks"
  tenant_id              = local.tenant_id
  bus_stack              = "app"
  env_stack              = "dev"
  loc_code               = "ne"
  region                 = "North Europe"
  dns_scope              = local.aks_dns_scope
  vnet_scope             = local.vnet_scope
  acr_scope              = local.acr_scope
  sku_tier               = "Standard"
  pri_cluster_enabled    = true
  pri_dns_zone_id        = local.dns_neaks
  pub_fqdn_enabled       = false
  http_app_route_enabled = false
  rbac_enabled           = true
  local_acc_disabled     = false
  az_rbac_enabled        = true
  kubes_version          = "1.34.2"
  np_orch_ver            = "1.34.2"
  np_name                = "apappdev"
  np_vm_size             = "Standard_D8s_v4"
  subnet_id              = azurerm_subnet.aks-subnet.id
  np_node_count          = "3"
  av_zones               = local.av_zones
  temp_name_rotation     = "devtemppool"
  nos_freq               = "RelativeMonthly"
  nos_int                = "1"
  nos_dur                = "4"
  nos_week               = "First"
  nos_day_week           = "Monday"
  nos_start_time         = "03:00"
  utc_offset             = "+00:00"
  net_plugin             = "azure"
  net_policy             = "cilium"
  net_dp                 = "cilium"
  net_pm                 = "overlay"
  lb_sku                 = "standard"
  svc_cidr               = "0.0.0.0/0"
  dns_svc_ip             = "0.0.0.0"
  resource_tags          = local.tags
}
```

## Inputs

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `tenant_id` | Entra tenant ID | string | Yes |
| `bus_stack` | Business unit identifier (e.g. app, ops) | string | Yes |
| `env_stack` | Environment stack (e.g. dev, uq, qual, pab, prod, dr) | string | Yes |
| `loc_code` | Abbreviated location code (e.g. ne, we) | string | Yes |
| `region` | Azure region | string | Yes |
| `dns_scope` | Scope for Private DNS Zone Contributor role assignment | string | Yes |
| `vnet_scope` | Scope for Network Contributor role assignment | string | Yes |
| `acr_scope` | Scope for AcrPull role assignment on the container registry | string | Yes |
| `sku_tier` | AKS SKU tier — Free, Standard or Premium | string | Yes |
| `pri_cluster_enabled` | Enable private cluster | string | Yes |
| `pri_dns_zone_id` | Private DNS Zone ID for the AKS cluster | string | Yes |
| `pub_fqdn_enabled` | Enable public FQDN for private cluster | string | Yes |
| `http_app_route_enabled` | Enable HTTP application routing | string | Yes |
| `rbac_enabled` | Enable RBAC | string | Yes |
| `az_rbac_enabled` | Enable Azure RBAC | string | Yes |
| `local_acc_disabled` | Disable local accounts | string | Yes |
| `kubes_version` | Kubernetes version | string | Yes |
| `np_name` | Node pool name | string | Yes |
| `np_vm_size` | Node pool VM size | string | Yes |
| `np_orch_ver` | Node pool orchestrator version | string | Yes |
| `np_node_count` | Number of nodes in the node pool | string | Yes |
| `subnet_id` | Subnet ID for the AKS node pool | string | Yes |
| `av_zones` | Availability zones | list(string) | Yes |
| `temp_name_rotation` | Temporary node pool name for rotation | string | Yes |
| `nos_freq` | Maintenance window frequency — Daily, Weekly, AbsoluteMonthly or RelativeMonthly | string | Yes |
| `nos_int` | Maintenance window interval | string | Yes |
| `nos_dur` | Maintenance window duration in hours (4–24) | string | Yes |
| `nos_week` | Week of month for maintenance — First, Second, Third, Fourth or Last | string | Yes |
| `nos_day_week` | Day of week for maintenance | string | Yes |
| `nos_start_time` | Maintenance start time (HH:mm) | string | Yes |
| `utc_offset` | UTC offset for maintenance timezone | string | Yes |
| `net_plugin` | Network plugin — azure, kubenet or none | string | Yes |
| `net_policy` | Network policy — cilium, calico or azure | string | Yes |
| `net_dp` | Network data plane — azure or cilium | string | Yes |
| `net_pm` | Network plugin mode — overlay | string | Yes |
| `lb_sku` | Load balancer SKU — standard | string | Yes |
| `svc_cidr` | Service CIDR for the AKS cluster | string | Yes |
| `dns_svc_ip` | DNS service IP within the AKS cluster | string | Yes |
| `resource_tags` | Resource tags map | map(string) | Yes |

## Outputs

| Output | Description |
|--------|-------------|
| `aks-id` | Resource ID of the AKS cluster |
| `aks-fqdn` | FQDN of the AKS cluster |
| `aks-pri-fqdn` | Private FQDN of the AKS cluster |
| `aks-por-fqdn` | Portal FQDN of the AKS cluster |
| `aks-identity` | Identity block with principal ID and tenant ID |
| `aks-node-rg` | Auto-generated node resource group name |
| `aks-node-rg-id` | Auto-generated node resource group ID |
| `aks-kube-id` | Kubelet identity — client ID, object ID and user-assigned identity ID |
| `aks-kube-admin-config` | Admin kube config with certificate and authentication details |
| `aks-kube-config` | Kube config with certificate and authentication details |

## Design Decisions

### User-Assigned Managed Identity

A user-assigned managed identity is created per cluster and assigned two roles before the cluster is provisioned — Private DNS Zone Contributor and Network Contributor. These are required for AKS to manage private DNS records and attach to the VNet. Using `depends_on` ensures the role assignments are in place before the cluster attempts to use them.

### Private Cluster

`private_cluster_enabled = true` means the AKS API server is only accessible from within the VWAN-connected private network. `pub_fqdn_enabled = false` ensures no public FQDN is registered. Access to the cluster for pipeline deployments and management is via the private network only.

### Cilium Network Policy

`net_policy = "cilium"` and `net_dp = "cilium"` enable the Cilium network data plane, providing advanced network policy enforcement, eBPF-based packet processing and improved observability over standard Azure or Calico policies. `net_pm = "overlay"` uses overlay networking to decouple pod IPs from the VNet address space, significantly reducing IP address consumption.

### Key Vault Secrets Provider

The Key Vault secrets provider add-on is enabled with secret rotation set to every 2 minutes. This allows pods to mount Key Vault secrets as volumes or environment variables, with automatic rotation ensuring pods always have current secret values without restarts.

### Maintenance Windows

Maintenance windows are fully configurable per environment, allowing clusters to be updated on staggered schedules — for example DEV on Monday, UAT on Tuesday, PROD on Thursday — preventing simultaneous updates across all environments.

### ACR Pull

The kubelet identity is assigned AcrPull on the container registry after cluster creation via a separate role assignment with `depends_on`. This allows all nodes to pull images from the private registry without storing credentials.

### Mandatory Tags

A `mandatory_tags` local merges `source = "terraform"` and `company = "pab"` into all resources alongside the caller-provided `resource_tags`, ensuring consistent tagging for cost management and governance.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

