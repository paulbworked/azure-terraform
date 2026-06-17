# environment-stack

Terraform code for deploying an individual application environment stack, containing all the data, messaging and secrets infrastructure required to run a single application environment.

## Overview

An **Environment Stack** is anything within an individual application environment, such as a Postgres instance, Service Bus Namespaces, Queues and Topics, a MongoDB cluster, storage accounts and key vaults — each with their associated private endpoints.

This folder contains a sanitised, real-world example of an environment stack. It sits alongside the Technical Stack (shared infrastructure) and is deployed once per environment (e.g. DEV, UAT, PROD).

## Files

| File | Description |
|------|-------------|
| `env_main.tf` | Resource group, application storage account, data module (PostgreSQL, Service Bus, MongoDB Atlas), PostgreSQL extensions and MongoDB developer user accounts with credentials stored in Key Vault |
| `env_kv.tf` | Environment Key Vault and PBI Key Vault, with all application secrets — PostgreSQL credentials, connection configuration, pgBouncer settings, MongoDB credentials, Service Bus configuration and application settings |

## Architecture Decisions

### Separation of Technical and Environment Stacks

The environment stack is deliberately separated from the technical stack. The technical stack (VNet, AKS, VM, shared storage) is deployed once and shared. The environment stack is deployed independently per environment, allowing environments to be created, updated or destroyed without affecting shared infrastructure.

### Data Module

A reusable Terraform module provisions the core data services in one call:
- **PostgreSQL Flexible Server** — private, subnet-delegated, with pgBouncer connection pooling configured via Key Vault secrets
- **Service Bus Namespace** — with network rules and private DNS integration
- **MongoDB Atlas** — cluster provisioned via the MongoDB Atlas Terraform provider, with project-level IP whitelisting and private endpoint integration

All connection strings, credentials and configuration values are stored in Key Vault rather than in code or state files.

### Two Key Vaults per Environment

| Key Vault | Purpose |
|-----------|---------|
| Application KV | PostgreSQL credentials, MongoDB credentials, Service Bus config, pgBouncer settings, application feature flags |
| PBI KV | Power BI authentication secrets — populated by the application pipeline, referenced by the application KV |

Separating PBI secrets into their own vault allows the application to manage its own secrets lifecycle independently of infrastructure.

### MongoDB Developer Accounts

Two MongoDB developer accounts are provisioned per environment and stored in Key Vault:
- **devadmin** — Atlas Admin role for development and migration tasks
- **devro** — readAnyDatabase role for read-only access

Passwords are generated at apply time via `random_password` and never hardcoded.

### PostgreSQL Configuration

PostgreSQL extensions are configured post-deployment (`CITEXT` enabled) via a separate resource with an explicit `depends_on` to ensure the server is fully provisioned before configuration is applied.

## What Is Not Included

The following supporting files are not included as they contain environment-specific references that cannot be meaningfully sanitised:

- `locals.tf` — local values including subnet IDs, DNS zone IDs, SKU definitions, service principal IDs and MongoDB Atlas organisation IDs
- `variables.tf` — input variables including region and tenant ID
- `provider.tf` — Azure and MongoDB Atlas provider configuration including subscription IDs and API keys

These are standard Terraform constructs — in a real deployment they would reference your own subscription IDs, resource names and environment-specific values.

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)
