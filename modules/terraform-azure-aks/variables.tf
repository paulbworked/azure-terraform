variable "tenant_id" {
  description = "the Entra tenant id"
  type        = string
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

variable "dns_scope" {
  description = "the full scope of the dns to assign the managed id to"
  type        = string
}

variable "vnet_scope" {
  description = "the full scope of the vnet to assign the managed id to"
  type        = string
}

variable "acr_scope" {
  description = "the full scope of the ACR to assign the managed id to"
  type        = string
}

variable "sku_tier" {
  description = "the SKU tier - Free, Standard or Premium"
  type        = string
}

variable "pri_cluster_enabled" {
  description = "whether the cluster is private or public enabled"
  type        = string
}

variable "pri_dns_zone_id" {
  description = "the Azure private dns zone hosted in Ops subscription"
  type        = string
}

variable "pub_fqdn_enabled" {
  description = "Specifies whether a Public FQDN for this Private Cluster should be added"
  type        = string
}

variable "http_app_route_enabled" {
  description = "Should HTTP Application Routing be enabled for this AKS cluster"
  type        = string
}

variable "rbac_enabled" {
  description = "Should RBAC be enabled for this AKS cluster"
  type        = string
}

variable "az_rbac_enabled" {
  description = "Should Azure RBAC be enabled for this AKS cluster. True = disabled"
  type        = string
}

variable "local_acc_disabled" {
  description = "is local accounts enabled or disabled"
  type        = string
}

variable "np_name" {
  description = "the name of the node pool"
  type        = string
}

variable "np_vm_size" {
  description = "the VM size of the AKS cluster"
  type        = string
}

variable "subnet_id" {
  description = "the subnet the AKS cluster is hosted"
  type        = string
}

variable "np_node_count" {
  description = "the number of nodes that exist in the node pool"
  type        = string
}

variable "nos_freq" {
  description = "Frequency of maintenance. Possible options are Daily, Weekly, AbsoluteMonthly and RelativeMonthly. AbsoluteMonthly is based on a specific date each month, while RelativeMonthly is based on a specific day of the week within a particular week of the month"
  type        = string

}

variable "nos_int" {
  description = "The interval for maintenance runs. Depending on the frequency this interval is week or month based."
  type        = string

}

variable "nos_dur" {
  description = "The duration of the window for maintenance to run in hours. Possible options are between 4 to 24. The duration should be specified in the ISO 8601 duration format. For example, if you want the duration to be 4 hours, it should be PT4H"
  type        = string

}

variable "nos_week" {
  description = "The week in the month used for the maintenance run. Options are First, Second, Third, Fourth, and Last."
  type        = string

}

variable "nos_day_week" {
  description = "The day of the week for the maintenance run. Required in combination with weekly frequency. Possible values are Friday, Monday, Saturday, Sunday, Thursday, Tuesday and Wednesday."
  type        = string

}

variable "nos_start_time" {
  description = "The time for maintenance to begin, based on the timezone determined by utc_offset. Format is HH:mm."
  type        = string

}

variable "utc_offset" {
  description = "Used to determine the timezone for cluster maintenance."
  type        = string

}

variable "net_plugin" {
  description = "plugin used for networking - azure, kubenet or none"
  type        = string
}

variable "net_policy" {
  description = "value to determine if should use cilium, calico or azure"
  type        = string
}

variable "net_dp" {
  description = "specifies which value to use when building out the kubernetes network, either azure or cilium"
  type        = string
}

variable "net_pm" {
  description = "used for building the AKS network - overlay"
  type        = string
}

variable "lb_sku" {
  description = "value to dtermine which load balance skuto use"
  type        = string

}

variable "svc_cidr" {
  description = "network range used by the AKS cluster"
  type        = string
}

variable "dns_svc_ip" {
  description = "IP address used within the AKS cluster"
  type        = string
}

variable "resource_tags" {
  description = "various tags depending on environment"
  type        = map(string)
}

variable "av_zones" {
  description = "The availability zones enabled"
  type        = list(string)
}

variable "temp_name_rotation" {
  description = "temporary name for rotation"
  type        = string
}

variable "kubes_version" {
  description = "version of kubernetes"
  type        = string
}

variable "np_orch_ver" {
  description = "version of orchestration agent"
  type        = string
}
