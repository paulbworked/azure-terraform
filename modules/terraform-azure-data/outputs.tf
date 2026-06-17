output "psql-id" {
  value       = azurerm_postgresql_flexible_server.psql.id
  description = "The ID of the PostgreSQL Flexible Server"
}

output "psql-fqdn" {
  value       = azurerm_postgresql_flexible_server.psql.fqdn
  description = "The FQDN of the PostgreSQL Flexible Server"
}

output "sbns-id" {
  value       = azurerm_servicebus_namespace.sb-ns.id
  description = "The ID of the Service Bus Namespace"
}

output "sbns-identity" {
  value       = azurerm_servicebus_namespace.sb-ns.identity
  description = "The identity block including tenant id and principal id of servicebus namespace"
}

output "mgdb-proj-id" {
  value       = mongodbatlas_project.mg-proj.id
  description = "The ID of the Mongo Atlas Project"
}

output "mgdb-cl-cid" {
  value       = mongodbatlas_advanced_cluster.mg-cl.cluster_id
  description = "The cluster ID of the Mongo Atlas Cluster"
}

# output "mgdb-cl-id" {
#   value       = mongodbatlas_advanced_cluster.mg-cl.id
#   description = "The ID of the Mongo Atlas Cluster"
# }

output "mgdb-cl-cs" {
  value       = mongodbatlas_advanced_cluster.mg-cl.connection_strings
  description = "The connection string of the Mongo Atlas Cluster"
}

output "mgdb-cl-ad-cs" {
  sensitive   = true
  value       = "mongodb+srv://${mongodbatlas_database_user.mg-admin-user.username}:${random_password.mg-admin-pw.result}@${replace(mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string, "mongodb+srv://", "")}/"
  description = "Connection string for admin access"
}

output "mgdb-cl-im-cs" {
  sensitive   = true
  value       = "mongodb+srv://${mongodbatlas_database_user.mg-import-user.username}:${random_password.mg-import-pw.result}@${replace(mongodbatlas_advanced_cluster.mg-cl.connection_strings.private_endpoint[0].srv_connection_string, "mongodb+srv://", "")}/"
  description = "Connection string for importer access"
}

output "mgdb-pl-ep-id" {
  value       = mongodbatlas_privatelink_endpoint_service.mg-pl-eps.interface_endpoint_id
  description = "The endpoint ID of the Mongo Atlas Private Link"
}

output "mgdb-pl-ep-cn" {
  value       = mongodbatlas_privatelink_endpoint_service.mg-pl-eps.private_endpoint_connection_name
  description = "The endpoint connection name of the Mongo Atlas Private Link"
}

output "mgdb-pl-ep-ip" {
  value       = mongodbatlas_privatelink_endpoint_service.mg-pl-eps.private_endpoint_ip_address
  description = "The endpoint IP of the Mongo Atlas Private Link"
}

output "mgdb-pl-ep-rid" {
  value       = mongodbatlas_privatelink_endpoint_service.mg-pl-eps.private_endpoint_resource_id
  description = "The resource ID of the Mongo Atlas Private Link"
}
