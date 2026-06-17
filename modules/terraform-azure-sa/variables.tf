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

variable "acc_kind" {
  description = "defines type of account - BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2"
  type        = string
}

variable "acc_tier" {
  description = "Defined the tier - Standard, Premium"
  type        = string
}

variable "acc_rep_type" {
  description = "defines type of replication - LRS, GRS, RAGRS, ZRS & RAGZRS"
  type        = string
}

variable "pub_net_acc" {
  description = "whether public network access is enabled - true or false"
  type        = string

}

variable "hns_enabled" {
  description = "defines if heirarchical namespace is enabled, used with Azure Data Lake Storage Gen 2, true or false but other pre-reqs required"
  type        = string

}

variable "nfs_enabled" {
  description = "defines if NFSv3 protocol is enabled, true or false but other pre-reqs required"
  type        = string
}

variable "sftp_enabled" {
  description = "defines if SFTP has been enabled - true or false"
  type        = string
}

variable "ver_enabled" {
  description = "defines if enabled - true or false"
  type        = string
}

variable "chan_feed_enabled" {
  description = "defines if the change feed properties have been enabled - true or false"
  type        = string
}

variable "blob_ret_days" {
  description = "defines the number of days to retain deleted blobs"
  type        = string
}

variable "con_ret_days" {
  description = "defines the number of days to retain deleted containers"
  type        = string
}

variable "restore_days" {
  description = "defines the number of days to keep restore points, needs to be less than above days"
  type        = string
}

variable "subnet_id" {
  description = "defines the subnet id of the pep"
  type        = string
}

variable "pri_zone_sa_blob" {
  description = "defines the private dns zone for blob storage account"
  type        = string
}
