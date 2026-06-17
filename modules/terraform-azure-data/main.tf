locals {
  mandatory_tags = {
    source  = "terraform"
    company = "pab"
  }
  applied_tags = merge(var.resource_tags, local.mandatory_tags)
}

# Get all members of Cloud Ops
data "azuread_group" "cloudops" {
  display_name               = "Cloud Operations"
  include_transitive_members = true
}

data "azuread_users" "admin_users" {
  object_ids = data.azuread_group.cloudops.members
}

################################################
#               POSTGRES SQL                   #
################################################

resource "azurerm_postgresql_flexible_server" "psql" {
  name                          = "psql-${var.bus_stack}-${var.env_stack}-${var.loc_code}"
  location                      = var.region
  resource_group_name           = var.rg_name
  version                       = var.postgres_version
  administrator_login           = var.psql_username
  administrator_password        = var.psql_kvs
  public_network_access_enabled = false
  delegated_subnet_id           = var.subnet_id_psql
  private_dns_zone_id           = var.pri_dns_zone_id_psql
  sku_name                      = var.psql_sku
  backup_retention_days         = var.psql_backup_retention_days
  storage_tier                  = var.psql_storage_tier
  storage_mb                    = var.psql_storage_mb
  auto_grow_enabled             = true
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled

  authentication {
    tenant_id                     = var.tenant_id
    active_directory_auth_enabled = true
  }
  dynamic "high_availability" {
    for_each = var.env_stack == "prod" ? ["this"] : []

    content {
      mode = "SameZone"
    }
  }

  lifecycle {
    ignore_changes = [
      zone, high_availability[0].standby_availability_zone
    ]
  }

  tags = local.applied_tags
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres-config-max-connections" {
  name      = "max_connections"
  server_id = azurerm_postgresql_flexible_server.psql.id
  value     = var.psql_max_con

  depends_on = [
    azurerm_postgresql_flexible_server.psql
  ]
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres-config-max-prep-transactions" {
  name      = "max_prepared_transactions"
  server_id = azurerm_postgresql_flexible_server.psql.id
  value     = var.psql_max_prep_tran

  depends_on = [
    azurerm_postgresql_flexible_server.psql
  ]
}


resource "azurerm_postgresql_flexible_server_active_directory_administrator" "postgres-admins" {
  count               = length(local.users.users)
  server_name         = azurerm_postgresql_flexible_server.psql.name
  resource_group_name = var.rg_name
  tenant_id           = var.tenant_id
  object_id           = local.users.users[count.index].object_id
  principal_name      = local.users.users[count.index].user_principal_name
  principal_type      = "User"

  depends_on = [
    azurerm_postgresql_flexible_server.psql
  ]
}

###############################################
#               SERVICE BUS                   #
###############################################

data "azurerm_subscription" "current" {
}

data "azuread_service_principal" "sp_core" {
  client_id = var.sp_core
}

data "azuread_service_principal" "sp_reportservice" {
  client_id = var.sp_reportservice
}

resource "azurerm_servicebus_namespace" "sb-ns" {
  name                          = "sbns-${var.bus_stack}-${var.env_stack}-${var.loc_code}"
  location                      = var.region
  resource_group_name           = var.rg_name
  sku                           = var.sbns_sku
  local_auth_enabled            = false
  capacity                      = var.sbns_sku == "Premium" ? 1 : 0
  premium_messaging_partitions  = var.sbns_sku == "Premium" ? 1 : 0
  public_network_access_enabled = var.sbns_pub_acc_en

  dynamic "network_rule_set" {
    for_each = var.sbns_sku == "Premium" ? [1] : []
    content {
      default_action                = var.sbns_nfs_def_action
      public_network_access_enabled = var.sbns_pub_acc_en
      trusted_services_allowed      = "true"
      ip_rules                      = var.sbns_ip_rules

      network_rules {
        subnet_id = var.sbns_snet_id
      }
    }
  }

  tags = local.applied_tags
}

resource "azurerm_private_endpoint" "sn-pe" {
  count                         = var.sbns_sku == "Premium" ? 1 : 0
  name                          = "${azurerm_servicebus_namespace.sb-ns.name}-pep"
  location                      = var.region
  resource_group_name           = var.rg_name
  subnet_id                     = var.subnet_id_pep
  custom_network_interface_name = "${azurerm_servicebus_namespace.sb-ns.name}-pep-nic"

  private_service_connection {
    name                           = "psc-${var.env_stack}${var.bus_stack}"
    private_connection_resource_id = azurerm_servicebus_namespace.sb-ns.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.pri_dns_zone_id_sbns]
  }

}

resource "azurerm_servicebus_queue" "sb-q" {
  for_each             = { for key, val in local.queue_names : key => val }
  name                 = "${local.queue_prefix}-${each.key}-${local.sb_loc_code}"
  namespace_id         = azurerm_servicebus_namespace.sb-ns.id
  partitioning_enabled = local.enable_partitioning
  requires_session     = each.value.session
}

resource "azurerm_servicebus_topic" "sb-t" {
  for_each             = local.topic_names
  name                 = "${local.topic_prefix}-${each.key}-${local.sb_loc_code}"
  namespace_id         = azurerm_servicebus_namespace.sb-ns.id
  partitioning_enabled = local.enable_partitioning
}

resource "azurerm_servicebus_subscription" "subscription-report" {
  for_each           = { for key, val in local.topic_names : key => val if val.report_service == true }
  name               = "${local.subscription_prefix}-${each.key}-${local.sb_loc_code}-report"
  topic_id           = "${data.azurerm_subscription.current.id}/resourceGroups/${var.rg_name}/providers/Microsoft.ServiceBus/namespaces/sbns-${var.bus_stack}-${var.env_stack}-${var.loc_code}/topics/${local.topic_prefix}-${each.key}-${local.sb_loc_code}"
  max_delivery_count = local.max_delivery_count

  depends_on = [
    azurerm_servicebus_topic.sb-t
  ]
}

resource "azurerm_servicebus_subscription" "subscription-cm2" {
  for_each           = { for key, val in local.topic_names : key => val if val.cm2 == true }
  name               = "${local.subscription_prefix}-${each.key}-${local.sb_loc_code}-cm2"
  topic_id           = "${data.azurerm_subscription.current.id}/resourceGroups/${var.rg_name}/providers/Microsoft.ServiceBus/namespaces/sbns-${var.bus_stack}-${var.env_stack}-${var.loc_code}/topics/${local.topic_prefix}-${each.key}-${local.sb_loc_code}"
  max_delivery_count = local.max_delivery_count
  requires_session   = each.value.session

  depends_on = [
    azurerm_servicebus_topic.sb-t
  ]
}

resource "azurerm_servicebus_subscription" "subscription-sm" {
  for_each           = { for key, val in local.topic_names : key => val if val.sm == true }
  name               = "${local.subscription_prefix}-${each.key}-${local.sb_loc_code}-sm"
  topic_id           = "${data.azurerm_subscription.current.id}/resourceGroups/${var.rg_name}/providers/Microsoft.ServiceBus/namespaces/sbns-${var.bus_stack}-${var.env_stack}-${var.loc_code}/topics/${local.topic_prefix}-${each.key}-${local.sb_loc_code}"
  max_delivery_count = local.max_delivery_count
  requires_session   = each.value.session

  depends_on = [
    azurerm_servicebus_topic.sb-t
  ]
}

resource "azurerm_role_assignment" "roleassignment_core" {
  scope                = azurerm_servicebus_namespace.sb-ns.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = data.azuread_service_principal.sp_core.object_id
}

resource "azurerm_role_assignment" "roleassignment_reportservice" {
  scope                = azurerm_servicebus_namespace.sb-ns.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = data.azuread_service_principal.sp_reportservice.object_id
}


###############################################
#               Mongo Atlas                   #
###############################################

resource "mongodbatlas_project" "mg-proj" {
  name   = "${var.bus_stack}-${var.env_stack}"
  org_id = var.at_org_id

  teams {
    team_id    = var.at_cloudops_team
    role_names = var.at_role_names
  }


}

resource "mongodbatlas_project_ip_access_list" "mg-proj-ip-whitelist" {
  project_id = mongodbatlas_project.mg-proj.id
  ip_address = var.mg_proj_ip_whitelist

  depends_on = [
    mongodbatlas_project.mg-proj
  ]
}

resource "mongodbatlas_privatelink_endpoint" "mg-pl-ep" {
  project_id    = mongodbatlas_project.mg-proj.id
  provider_name = "AZURE"
  region        = var.mg_az_reg_name
}

resource "azurerm_private_endpoint" "mg-pl-pep" {
  name                          = "mg-${var.bus_stack}-${var.env_stack}-pep"
  location                      = var.region
  resource_group_name           = var.rg_name
  subnet_id                     = var.subnet_id_pep
  custom_network_interface_name = "mg-${var.bus_stack}-${var.env_stack}-nic"

  private_service_connection {
    name                           = mongodbatlas_privatelink_endpoint.mg-pl-ep.private_link_service_name
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.mg-pl-ep.private_link_service_resource_id
    is_manual_connection           = true
    request_message                = "setting up the link"
  }

  depends_on = [
    mongodbatlas_privatelink_endpoint.mg-pl-ep
  ]

}

resource "mongodbatlas_privatelink_endpoint_service" "mg-pl-eps" {
  project_id                  = mongodbatlas_privatelink_endpoint.mg-pl-ep.project_id
  private_link_id             = mongodbatlas_privatelink_endpoint.mg-pl-ep.private_link_id
  endpoint_service_id         = azurerm_private_endpoint.mg-pl-pep.id
  private_endpoint_ip_address = azurerm_private_endpoint.mg-pl-pep.private_service_connection.0.private_ip_address
  provider_name               = "AZURE"

  depends_on = [
    mongodbatlas_privatelink_endpoint.mg-pl-ep, azurerm_private_endpoint.mg-pl-pep
  ]

}

resource "mongodbatlas_advanced_cluster" "mg-cl" {
  project_id   = mongodbatlas_project.mg-proj.id
  name         = "${var.bus_stack}-${var.env_stack}"
  cluster_type = var.mg_cluster_type

  replication_specs = [ {
    
    region_configs = [ {
        electable_specs = {
        instance_size = var.mg_instance_size
        node_count    = var.mg_node_count
        disk_size_gb  = var.mg_disk_size_gb
      }

      auto_scaling = {
        disk_gb_enabled = var.mg_disk_gb_enabled
      }

      provider_name = "AZURE"
      priority      = var.mg_priority
      region_name   = var.mg_region_name

    } ]


  } ]

  mongo_db_major_version = var.mg_db_version
  pit_enabled            = var.mg_pit_enabled
  backup_enabled         = var.mg_backup_enabled

  advanced_configuration = {
    minimum_enabled_tls_protocol = "TLS1_2"
    oplog_size_mb                = var.mg_oplog_size
  }

  lifecycle {
    ignore_changes = [
      replication_specs[0].region_configs[0].electable_specs.disk_size_gb,
      replication_specs[0].region_configs[0].electable_specs.instance_size,
      replication_specs[0].region_configs[0].electable_specs.disk_iops,
      replication_specs[0].region_configs[0].electable_specs.node_count
    ]
  }

  depends_on = [
    mongodbatlas_project.mg-proj,
    mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]

}


resource "mongodbatlas_cloud_backup_schedule" "mg-cb" {
  count        = var.mg_backup_enabled == "true" ? 1 : 0
  project_id   = mongodbatlas_project.mg-proj.id
  cluster_name = mongodbatlas_advanced_cluster.mg-cl.name

  reference_hour_of_day    = 23
  reference_minute_of_hour = 59
  restore_window_days      = 7

  policy_item_hourly {
    frequency_interval = 6
    retention_unit     = "days"
    retention_value    = 7
  }

  policy_item_daily {
    frequency_interval = 1
    retention_unit     = "days"
    retention_value    = 7
  }

  policy_item_weekly {
    frequency_interval = 6
    retention_unit     = "weeks"
    retention_value    = 4
  }

  policy_item_monthly {
    frequency_interval = 40
    retention_unit     = "months"
    retention_value    = 12
  }

  dynamic "copy_settings" {
    for_each = var.env_stack == "prod" ? ["this"] : []

    content {
      cloud_provider = "AZURE"
      frequencies = [
        "HOURLY", "DAILY", "WEEKLY", "MONTHLY"
      ]
      region_name        = "FRANCE_CENTRAL"
      zone_id            = mongodbatlas_advanced_cluster.mg-cl.replication_specs[0].*.zone_id[0]
      should_copy_oplogs = false
    }
  }

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]

}

resource "mongodbatlas_maintenance_window" "mg-mw" {
  project_id  = mongodbatlas_project.mg-proj.id
  day_of_week = 1
  hour_of_day = 5

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]

}

###############################################
#             Mongo Login/Passwords           #
###############################################

# Mongo Admin Account
resource "mongodbatlas_database_user" "mg-admin-user" {
  project_id         = mongodbatlas_project.mg-proj.id
  username           = "admin-${var.env_stack}"
  password           = random_password.mg-admin-pw.result
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]
}

resource "random_password" "mg-admin-pw" {
  length      = 26
  min_lower   = 4
  min_upper   = 4
  min_numeric = 4
  special     = false

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]

}

# Pushing Admin user name into KV
resource "azurerm_key_vault_secret" "mg-admin-us-kv" {
  name         = "mongodb-cl-admin-user"
  value        = mongodbatlas_database_user.mg-admin-user.username
  content_type = "MongoDB admin user"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]

}

# Pushing Admin password into KV
resource "azurerm_key_vault_secret" "mg-admin-pw-kv" {
  name         = "mongodb-cl-admin-password"
  value        = random_password.mg-admin-pw.result
  content_type = "MongoDB admin password"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]

}

# Mongo Importer Account
resource "mongodbatlas_database_user" "mg-import-user" {
  project_id         = mongodbatlas_project.mg-proj.id
  username           = "pab_import"
  password           = random_password.mg-import-pw.result
  auth_database_name = "admin"

  roles {
    role_name     = "readAnyDatabase"
    database_name = "admin"
  }

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]

}

resource "random_password" "mg-import-pw" {
  length      = 26
  min_lower   = 4
  min_upper   = 4
  min_numeric = 4
  special     = false

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]

}

# Pushing Importer user name into KV
resource "azurerm_key_vault_secret" "mg-import-us-kv" {
  name         = "mongodb-cl-import-user"
  value        = mongodbatlas_database_user.mg-import-user.username
  content_type = "MongoDB import user"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]

}

# Pushing Impoter password into KV
resource "azurerm_key_vault_secret" "mg-import-ps-kv" {
  name         = "mongodb-cl-import-password"
  value        = random_password.mg-import-pw.result
  content_type = "MongoDB import password"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]

}

###############################################
#             Mongo KV Strings                #
###############################################

# A set of strings imported into the env stack KV, for informational use

resource "azurerm_key_vault_secret" "mg-std-cs-kv" {
  name         = "mongodb-standard-cs-for-information-only"
  value        = mongodbatlas_advanced_cluster.mg-cl.connection_strings.standard
  content_type = "Connection String - standard connection string for the cluster"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_advanced_cluster.mg-cl
  ]
}

resource "azurerm_key_vault_secret" "mg-pe-cs-kv" {
  name         = "mongodb-privateendpoint-cs-for-information-only"
  value        = mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].connection_string
  content_type = "Connection String - private endpoint connection string for the cluster"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_database_user.mg-admin-user, random_password.mg-admin-pw, mongodbatlas_advanced_cluster.mg-cl,
    mongodbatlas_privatelink_endpoint.mg-pl-ep, mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]
}

resource "azurerm_key_vault_secret" "mg-pe-srv-cs-kv" {
  name         = "mongodb-privateendpoint-srv-cs-for-information-only"
  value        = mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string
  content_type = "Connection String - private endpoint srv connection string for the cluster"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_database_user.mg-admin-user, random_password.mg-admin-pw, mongodbatlas_advanced_cluster.mg-cl,
    mongodbatlas_privatelink_endpoint.mg-pl-ep, mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]
}

# A set of application connection strings imported into the env stack KV

resource "azurerm_key_vault_secret" "mg-dpdq-cs-kv" {
  name         = "pab5-deletepdquery-mongo-system"
  value        = "mongodb+srv://${mongodbatlas_database_user.mg-admin-user.username}:${random_password.mg-admin-pw.result}@${replace(mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string, "mongodb+srv://", "")}/"
  content_type = "Connection String"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_database_user.mg-admin-user, random_password.mg-admin-pw, mongodbatlas_advanced_cluster.mg-cl,
    mongodbatlas_privatelink_endpoint.mg-pl-ep, mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]
}

resource "azurerm_key_vault_secret" "mg-sys-cs-kv" {
  name         = "pab5-mongo-system"
  value        = "mongodb+srv://${mongodbatlas_database_user.mg-admin-user.username}:${random_password.mg-admin-pw.result}@${replace(mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string, "mongodb+srv://", "")}/?retryWrites=true&w=majority"
  content_type = "Connection String"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_database_user.mg-admin-user, random_password.mg-admin-pw, mongodbatlas_advanced_cluster.mg-cl,
    mongodbatlas_privatelink_endpoint.mg-pl-ep, mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]
}

resource "azurerm_key_vault_secret" "mg-eu-cs-kv" {
  name         = "pab5-mongo-eu"
  value        = "mongodb+srv://${mongodbatlas_database_user.mg-admin-user.username}:${random_password.mg-admin-pw.result}@${replace(mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string, "mongodb+srv://", "")}/?retryWrites=true&w=majority"
  content_type = "Connection String"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_database_user.mg-admin-user, random_password.mg-admin-pw, mongodbatlas_advanced_cluster.mg-cl,
    mongodbatlas_privatelink_endpoint.mg-pl-ep, mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]
}

resource "azurerm_key_vault_secret" "mg-us-cs-kv" {
  name         = "pab5-mongo-us"
  value        = "mongodb+srv://${mongodbatlas_database_user.mg-admin-user.username}:${random_password.mg-admin-pw.result}@${replace(mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string, "mongodb+srv://", "")}/?retryWrites=true&w=majority"
  content_type = "Connection String"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_database_user.mg-admin-user, random_password.mg-admin-pw, mongodbatlas_advanced_cluster.mg-cl,
    mongodbatlas_privatelink_endpoint.mg-pl-ep, mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]
}

resource "azurerm_key_vault_secret" "mg-im-eu-cs-kv" {
  name         = "pab5-importer-mongo-eu"
  value        = "mongodb+srv://${mongodbatlas_database_user.mg-import-user.username}:${random_password.mg-import-pw.result}@${replace(mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string, "mongodb+srv://", "")}/?retryWrites=true&w=majority"
  content_type = "Connection String"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_database_user.mg-admin-user, random_password.mg-admin-pw, mongodbatlas_advanced_cluster.mg-cl,
    mongodbatlas_privatelink_endpoint.mg-pl-ep, mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]
}

resource "azurerm_key_vault_secret" "mg-im-us-cs-kv" {
  name         = "pab5-importer-mongo-us"
  value        = "mongodb+srv://${mongodbatlas_database_user.mg-import-user.username}:${random_password.mg-import-pw.result}@${replace(mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string, "mongodb+srv://", "")}/?retryWrites=true&w=majority"
  content_type = "Connection String"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_database_user.mg-admin-user, random_password.mg-admin-pw, mongodbatlas_advanced_cluster.mg-cl,
    mongodbatlas_privatelink_endpoint.mg-pl-ep, mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]
}

resource "azurerm_key_vault_secret" "mg-im-sys-cs-kv" {
  name         = "pab5-importer-mongo-system"
  value        = "mongodb+srv://${mongodbatlas_database_user.mg-import-user.username}:${random_password.mg-import-pw.result}@${replace(mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string, "mongodb+srv://", "")}/?retryWrites=true&w=majority"
  content_type = "Connection String"
  key_vault_id = var.kv_id

  depends_on = [
    mongodbatlas_database_user.mg-admin-user, random_password.mg-admin-pw, mongodbatlas_advanced_cluster.mg-cl,
    mongodbatlas_privatelink_endpoint.mg-pl-ep, mongodbatlas_privatelink_endpoint_service.mg-pl-eps
  ]
}
