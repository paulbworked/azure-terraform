variable "rg_name" {
  description = "Resource Group Name"
  type        = string
}

variable "vmname" {
  description = "Name of virtual machine"
  type        = string
}

variable "env" {
  description = "environment stack - might be dev, prod, dr"
  type        = string
  default     = "null"
}

variable "region" {
  description = "Azure Region"
  type        = string
}

variable "location_code" {
  description = "Shorthand of region"
  type        = string
}

variable "vm_size" {
  description = "Machine Size"
  type        = string
}

variable "osdisk_type" {
  description = "Storage Account Type"
  type        = string
}

variable "publisher" {
  description = "OS Publisher"
  type        = string
}

variable "offer" {
  description = "OS Offer"
  type        = string
}

variable "sku" {
  description = "SKU of server"
  type        = string
}

variable "timezone" {
  description = "Timezone"
  type        = string
}

variable "subnet_id" {
  description = "ID of subnet of virtual network"
  type        = string
}

variable "static_ip_address" {
  description = "Static IP address of NIC on virtual machine"

}

variable "vm_adminuser" {
  description = "local admin account"
  type        = string
}

variable "vm_adminpass" {
  description = "Password of local admin account"
  type        = string
}

variable "resource_tags" {
  description = "various tags depending on environment"
  type        = map(string)
}

variable "lic_type" {
  description = "Licence type of server - Windows_Server is Hybrid"
  type = string
}
