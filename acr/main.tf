# RG for the Azure Container Registry
resource "azurerm_resource_group" "acr-ops-rg" {
  name     = "rg-acr"
  location = var.region_ne

  tags = local.tags
}

resource "azurerm_container_registry" "acr-ops" {
  name                = "pabregistry"
  location            = var.region_ne
  resource_group_name = azurerm_resource_group.acr-ops-rg.name
  sku                 = "Premium"

  public_network_access_enabled = false
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = false
  export_policy_enabled         = false
  quarantine_policy_enabled     = false
  retention_policy_in_days      = 7
  trust_policy_enabled          = false
  zone_redundancy_enabled       = false

  network_rule_bypass_option = "AzureServices"
  network_rule_set = [{
    default_action = "Deny"
    ip_rule        = []
  }]

  georeplications {
    location                  = "westeurope"
    regional_endpoint_enabled = true
    tags                      = local.tags
    zone_redundancy_enabled   = false
  }

  tags = local.tags
}

# Create a Private Endpoint to make the acr private only via the Azure VPN
resource "azurerm_private_endpoint" "sn-pe" {
  name                          = "${azurerm_container_registry.acr-ops.name}-pep"
  location                      = var.region_ne
  resource_group_name           = azurerm_resource_group.acr-ops-rg.name
  subnet_id                     = local.snet_pep_id
  custom_network_interface_name = "${azurerm_container_registry.acr-ops.name}-pep-nic"
  tags                          = local.tags

  private_service_connection {
    name                           = "psc-${azurerm_container_registry.acr-ops.name}"
    private_connection_resource_id = azurerm_container_registry.acr-ops.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.pri_dns_acr_id]
  }
}

# Assign AKS clusters pull permission
resource "azurerm_role_assignment" "roleassignment_aks_acr_pull" {
  for_each = local.aks_ids

  scope                = azurerm_container_registry.acr-ops.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}

# Assign software engineers AcrPull
resource "azurerm_role_assignment" "roleassignment_eng_acr_pull" {
  for_each = local.eng_ids

  scope                = azurerm_container_registry.acr-ops.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}

# Assign Windows VMSS pull permission
resource "azurerm_role_assignment" "role-vmss-win-pull" {
  scope                = azurerm_container_registry.acr-ops.id
  role_definition_name = "AcrPull"
  principal_id         = local.mi_vmss_win
}

# Assign Windows VMSS push permission
resource "azurerm_role_assignment" "role-vmss-win-push" {
  scope                = azurerm_container_registry.acr-ops.id
  role_definition_name = "AcrPush"
  principal_id         = local.mi_vmss_win
}

# Assign Linux VMSS pull permission
resource "azurerm_role_assignment" "role-vmss-lin-pull" {
  scope                = azurerm_container_registry.acr-ops.id
  role_definition_name = "AcrPull"
  principal_id         = local.mi_vmss_lin
}

# Assign Linux VMSS push permission
resource "azurerm_role_assignment" "role-vmss-lin-push" {
  scope                = azurerm_container_registry.acr-ops.id
  role_definition_name = "AcrPush"
  principal_id         = local.mi_vmss_lin
}
