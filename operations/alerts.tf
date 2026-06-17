# Create the main operations monitor resource group
resource "azurerm_resource_group" "monitor-rg" {
  name     = "rg-alerts"
  location = "North Europe"

  tags = local.tags
}

# Create action group for operations
resource "azurerm_monitor_action_group" "ag-operations" {
  name                = "ag-cloudops"
  resource_group_name = azurerm_resource_group.monitor-rg.name
  short_name          = "agcloudops"

  email_receiver {
    name          = "TeamMember1"
    email_address = "cloudops@example.com"
  }

  email_receiver {
    name          = "TeamMember2"
    email_address = "cloudops@example.com"
  }

  email_receiver {
    name          = "TeamMember3"
    email_address = "cloudops@example.com"
  }

  email_receiver {
    name          = "TeamMember4"
    email_address = "cloudops@example.com"
  }

  tags = local.tags
}

# Create Azure Service Health Alert for service issues
resource "azurerm_monitor_activity_log_alert" "azure-svchealth" {
  name                = "All Service Health Alert - Service Issue"
  resource_group_name = azurerm_resource_group.monitor-rg.name
  # sanitised
  scopes   = ["/subscriptions/00000000-0000-0000-0000-000000000000"]
  location = "Global"

  criteria {
    category = "ServiceHealth"

    service_health {
      events = ["Incident"]
      locations = [
        "Central US",
        "East US",
        "East US 2",
        "France Central",
        "Germany West Central",
        "North Europe",
        "UK South",
        "UK West",
        "West Europe",
        "West US",
      "Global"]

    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag-operations.id
  }

}

# removed all the others I have set up
