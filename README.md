# azure-terraform

A collection of sanitised Terraform code for deploying and managing enterprise-grade Azure infrastructure, based on real-world production deployments.

## Overview

This repository demonstrates infrastructure patterns and best practices for building secure, scalable, and highly available Azure environments. All code is sanitised — no real credentials, subscription IDs, IP ranges, or company-specific configurations are included.

## Structure

| Folder | Description |
|--------|-------------|
| `network` | Virtual WAN, Firewall, VNets, NSGs, Private DNS, VPN |
| `operations` | Monitoring, alerting, Key Vaults, Storage, shared services |
| `example-environment` | Reference architecture — full environment stack end to end |
| `acr` | Azure Container Registry, access policies, replication |
| `agents` | Azure DevOps self-hosted agent infrastructure |
| `image` | VM images and Azure image galleries |
| `sftp` | SFTP-enabled storage accounts for secure file transfer |
| `modules` | Reusable Terraform modules used across the repository |

## Principles

- All environments built private by default — no public exposure
- Infrastructure as Code via Terraform and HCP Terraform Cloud
- Consistent governance: Management Groups, RBAC, Azure Policy
- Modular and reusable — designed to scale

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)
