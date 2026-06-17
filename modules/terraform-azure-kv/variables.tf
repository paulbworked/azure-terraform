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

variable "sku" {
  description = "SKU of KV"
  type        = string
}

variable "subnet_id" {
  description = "ID of subnet in VNET"
  type        = string
}

variable "pri_zone_kv" {
  description = "private dns zone for KV"
  type        = string
}

variable "subnet_id_ops-ci" {
  description = "ID of container instance subnet on OPs vnet"
  type        = string
}

variable "resource_tags" {
  description = "various tags depending on environment"
  type        = map(string)
}

variable "public_enabled" {
  description = "whether public access is enabled or not - true/false"
  type        = bool
}

variable "rbac_enabled" {
  description = "whether rbac is enabled or not - true/false"
  type        = bool
}

variable "kv_ips" {
  description = "list of IPs allowed to access the kv"
  type        = list(string)
}
