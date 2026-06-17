variable "tenant_id" {
  type        = string
  description = "The Azure tenant ID"
}

variable "resource_tags" {
  description = "various tags depending on environment"
  type        = map(string)
}

variable "bus_stack" {
  description = "business unit - stack might be pab, ops, app etc"
  type        = string
}

variable "env_stack" {
  description = "environment stack - might be dev, uq, qual, val, prod, dr"
  type        = string
}

variable "loc_code" {
  description = "abbreviated location code"
  type        = string
}

variable "region" {
  description = "Azure region"
  type        = string
}

variable "rg_name" {
  description = "resource group name"
  type        = string
}

variable "postgres_version" {
  type        = string
  description = "Postgres version - 11,12,13,14,15,16"
}

variable "psql_username" {
  type        = string
  description = "The username for the local Postgres admin"
}

variable "psql_kvs" {
  type        = string
  description = "The key vault where the local password is stored"
  sensitive   = true
}

variable "subnet_id_psql" {
  description = "the subnet the PSQL is hosted on"
  type        = string
}

variable "pri_dns_zone_id_psql" {
  description = "the Azure private dns zone hosted in Ops subscription"
  type        = string
}

variable "pri_dns_zone_id_sbns" {
  description = "the Azure private dns zone hosted in Ops subscription"
  type        = string
}

variable "psql_sku" {
  type        = string
  description = "Azure SKU of the Postgres server - B_Standard_B1ms, GP_Standard_d2s_v3"
}

variable "psql_backup_retention_days" {
  type        = number
  description = "Number of days to retain the backups - values between 7-35 days"
}

variable "psql_storage_tier" {
  type        = string
  description = "Storage tier of the Postgres server. e.g. 'P4', P6, P10, P15, P20, P30, P40, P50, P60, P70, P80"
}

variable "psql_storage_mb" {
  type        = number
  description = "Storage MB for Postgres server - 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216 and 33553408"
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = "Enable geo redundancy backups - true or false"
}

variable "psql_max_con" {
  type        = number
  description = "the maximum connections that can be made to the Postgres server."
}

variable "psql_max_prep_tran" {
  type        = number
  description = "the maximum connections that can be made to the Postgres server."
}

variable "sp_core" {
  type        = string
  description = "Service Principal Client ID for core."
}

variable "sp_reportservice" {
  type        = string
  description = "Service Principal Client ID for report service."
}

variable "sbns_sku" {
  type        = string
  description = "Azure SKU of the Service Bus Namespace - Basic, Standard or Premium"
}

variable "sbns_pub_acc_en" {
  type        = string
  description = "Whether public access is enabled on the Service Bus or not"
}

variable "sbns_nfs_def_action" {
  type        = string
  description = "Specifies the default action for the Network Rule Set. Should be Deny to enable only access from vnets and firewalled ip_rules"

}

variable "sbns_ip_rules" {
  type        = list(string)
  description = "List of IP addresses or CIDR blocks allowed to access the Service Bus namespace"
}

variable "sbns_snet_id" {
  type        = string
  description = "The Subnet ID which should be able to access this ServiceBus Namespace."

}

variable "at_org_id" {
  type        = string
  description = "Location of Atlas Org key, in the Ops Key Vault"
}

variable "at_cloudops_team" {
  type = string
  description = "Name/ID of CloudOps team in Atlas"
  
}

variable "at_role_names" {
  type = list(string)
  description = "List of roles to apply to team/id"
  
}

variable "mg_proj_ip_whitelist" {
  type        = string
  description = "IPs to whitelist access to the Atlas MongoDB project"
}

variable "mg_cluster_type" {
  type        = string
  description = "type of Atlas MongoDB cluster - REPLICASET, SHARDED, GLOBAL & SERVERLESS"
}

variable "mg_instance_size" {
  type        = string
  description = "instance size of the cluster - M10, M20, M30 & M40 etc"
}

variable "mg_node_count" {
  type        = number
  description = "Number of electable nodes to deploy in the specified region - 0, 3, 5 & 7"
}

variable "mg_disk_gb_enabled" {
  type        = bool
  description = "Part of the auto-scaling configuration. When set to true, it enables automatic scaling of the disk size for the cluster - true/false"
}

variable "mg_disk_size_gb" {
  type        = number
  description = "Maximum size of the cluster - 16, 32, 64 etc"
}

variable "mg_priority" {
  type        = number
  description = "Number that indicates the election priority of the region. To identify the Preferred Region of the cluster, set this parameter to 7. The primary node runs in the Preferred Region. To identify a read-only region, set this parameter to 0 - 0-7"
}

variable "mg_region_name" {
  type        = string
  description = "Region where cluster is located - EUROPE_NORTH, EUROPE_WEST etc"
}

variable "mg_db_version" {
  type        = string
  description = "Version of the cluster to deploy. Atlas supports the following MongoDB versions for M10+ clusters: 4.4, 5.0, 6.0 or 7.0"
}

variable "mg_pit_enabled" {
  type        = bool
  description = "Point in time enabled - true or false"
}

variable "mg_backup_enabled" {
  type        = bool
  description = "Backup enabled - true or false"
}

variable "mg_oplog_size" {
  type        = number
  description = "Size of oplog - 10000 or 40000 depending on configuration of cluster"
}

variable "subnet_id_pep" {
  type        = string
  description = "Subnet value where private endpoints are located"
}

variable "mg_az_reg_name" {
  type        = string
  description = "Region where Azure PL is created in Azure - northeurope, westeurope, uksouth, ukwest, francecentral etc"
}

variable "kv_id" {
  type        = string
  description = "ID of stack key vault"
}

variable "sb_loc_code" {
  type        = string
  description = "Abbreviation of the Azure location. e.g. 'eun'. Hopefully this is temporary"
  default     = "eun"
}
