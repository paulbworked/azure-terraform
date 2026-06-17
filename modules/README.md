# data

A reusable Terraform module that provisions three core data services in a single call — PostgreSQL Flexible Server, Azure Service Bus Namespace and MongoDB Atlas cluster — along with all associated configuration, private endpoints, user accounts and connection strings stored in Key Vault.

## Overview

This module encapsulates the full data layer of an application environment stack. Rather than managing three separate sets of resources across multiple files, this module provides a single interface for deploying and configuring all data services consistently across environments. All credentials are generated at apply time and stored directly into Key Vault — nothing is hardcoded.

## Files

| File | Description |
|------|-------------|
| `main.tf` | PostgreSQL Flexible Server with AD authentication and server configuration, Service Bus Namespace with queues, topics and subscriptions, MongoDB Atlas project, cluster, private link endpoint and all user accounts and connection strings stored in Key Vault |
| `locals.tf` | Queue names, topic names, subscription configuration, Service Bus naming prefixes and partitioning logic |
| `variables.tf` | All input variables for all three services — stack identifiers, region, PostgreSQL config, Service Bus config and MongoDB Atlas config |
| `outputs.tf` | Outputs for PostgreSQL ID and FQDN, Service Bus Namespace ID and identity, MongoDB Atlas project ID, cluster ID, connection strings and private link endpoint details |
| `provider.tf` | MongoDB Atlas provider configuration |

## Services Provisioned

### PostgreSQL Flexible Server

- Private, subnet-delegated server with Entra Active Directory authentication enabled
- Configurable SKU, storage tier, storage size, backup retention and geo-redundant backup
- High availability (SameZone) automatically enabled for production environments via dynamic block
- `max_connections` and `max_prepared_transactions` configured post-deployment
- Cloud Operations group members automatically added as AD administrators

### Azure Service Bus Namespace

- Configurable SKU — Standard or Premium
- Network rule set (Premium only) with IP rules and subnet access controls, private endpoint deployed for Premium SKU
- Queues and topics defined in `locals.tf` and deployed via `for_each` — easy to extend without changing module code
- Subscriptions created per topic for report service, CM2 and SM consumers
- Service Principal role assignments for application services (Azure Service Bus Data Owner)
- Partitioning automatically disabled for Premium SKU and enabled for Standard

### MongoDB Atlas

- Atlas project with team role assignments and IP access list
- Advanced cluster with configurable instance size, node count, disk size, region and MongoDB version
- Private link endpoint (Azure PrivateLink) provisioned end-to-end — Atlas endpoint → Azure private endpoint → endpoint service registration
- Cloud backup schedule with hourly, daily, weekly and monthly policies; cross-region copy enabled for production environments
- Maintenance window configured
- Admin and importer user accounts provisioned with passwords generated via `random_password` and stored in Key Vault
- Standard, private endpoint and SRV connection strings stored in Key Vault for application use

## Architecture Decisions

### Single Module for Three Services

PostgreSQL, Service Bus and MongoDB are always deployed together as the data layer of an environment stack. Combining them into a single module ensures consistent naming, tagging and dependency ordering, and reduces the number of module calls needed in the environment stack.

### Credentials in Key Vault

All passwords and connection strings are generated at apply time and written directly into Key Vault. No credentials are stored in Terraform state in plain text beyond what Terraform itself manages. Sensitive outputs are marked `sensitive = true`.

### Dynamic Service Bus Configuration

Queues and topics are defined as maps in `locals.tf` rather than individual resources. Adding or removing a queue or topic requires only a change to the local map — no new resource blocks needed. Subscriptions are filtered from the same topic map using `for_each` with a condition on the consumer flag (`report_service`, `cm2`, `sm`).

### MongoDB Private Link

MongoDB Atlas Private Link requires a three-step process — Atlas endpoint creation, Azure private endpoint creation and endpoint service registration — with strict `depends_on` ordering. This is handled within the module so callers don't need to manage the sequencing.

### Environment-Aware Resources

Two resources adapt automatically based on `env_stack`:
- **PostgreSQL high availability** — SameZone HA only enabled for `prod`
- **MongoDB backup cross-region copy** — only enabled for `prod`

This prevents unnecessary cost in non-production environments while ensuring production has the appropriate resilience.

## What Is Not Included

`provider.tf` contains only the MongoDB Atlas provider version constraint — no API keys or credentials. These must be supplied via environment variables or a secrets manager in the calling environment.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

