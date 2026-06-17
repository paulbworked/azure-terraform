output "aks-id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "returns the ID of the AKS cluster"
}

output "aks-fqdn" {
  value       = azurerm_kubernetes_cluster.aks.fqdn
  description = "returns the FQDN of the AKS cluster"
}

output "aks-pri-fqdn" {
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
  description = "returns the private FQDN of the AKS cluster"
}

output "aks-por-fqdn" {
  value       = azurerm_kubernetes_cluster.aks.portal_fqdn
  description = "returns the portal FQDN of the AKS cluster"
}

output "aks-identity" {
  value       = azurerm_kubernetes_cluster.aks.identity
  description = "returns the principal ID and tenant ID associated with Managed Service identity"
}

output "aks-node-rg" {
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
  description = "returns the auto-generated rg which contains the resources for AKS"
}

output "aks-node-rg-id" {
  value       = azurerm_kubernetes_cluster.aks.node_resource_group_id
  description = "returns the ID of the auto-generated rg which contains the resources for AKS"
}

output "aks-kube-id" {
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity
  description = "returns client_id, object_id and user_assigned_identity_id of user-defined managed identity assigned to the kubelets"
}

output "aks-kube-admin-config" {
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config
  description = "returns certificate and username password authentication details for cluster"
}

output "aks-kube-config" {
  value       = azurerm_kubernetes_cluster.aks.kube_config
  description = "returns certificate and username password authentication details for cluster"
}

