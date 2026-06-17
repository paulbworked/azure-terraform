output "kv-id" {
  value       = azurerm_key_vault.kv.id
  description = "outputs the id name of the kv"
}

output "vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
  description = "outputs the uri of the kv"
}