output "storage_account_name" {
  value       = azurerm_storage_account.sa.name
  description = "returns the name of the storage account"
}

output "id" {
  value       = azurerm_storage_account.sa.id
  description = "returns ID of the storage account"
}

output "identity" {
  value       = azurerm_storage_account.sa.identity
  description = "returns principal ID and tenant ID"
}

output "primary_access_key" {
  value       = azurerm_storage_account.sa.primary_access_key
  description = "returns value of primary access key"
}

output "secondary_access_key" {
  value       = azurerm_storage_account.sa.secondary_access_key
  description = "returns value of secondary access key"
}

output "primary_connection_string" {
  value       = azurerm_storage_account.sa.primary_connection_string
  description = "returns value of primary connection string"
}

output "secondary_connection_string" {
  value       = azurerm_storage_account.sa.secondary_connection_string
  description = "returns value of secondary connection string"
}

output "primary_blob_connection_string" {
  value       = azurerm_storage_account.sa.primary_blob_connection_string
  description = "returns connection string associated with the primary blob"
}

output "secondary_blob_connection_string" {
  value       = azurerm_storage_account.sa.secondary_connection_string
  description = "returns connection string associated with the secondary blob"
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.sa.primary_blob_endpoint
  description = "returns the endpoint url for blob storage"
}

output "secondary_blob_endpoint" {
  value       = azurerm_storage_account.sa.secondary_blob_endpoint
  description = "returns the endpoint url for blob storage"
}

output "primary_file_endpoint" {
  value       = azurerm_storage_account.sa.primary_file_endpoint
  description = "returns the endpoint url for file storage"
}

output "secondary_file_endpoint" {
  value       = azurerm_storage_account.sa.secondary_file_endpoint
  description = "returns the endpoint url for file storage"
}
