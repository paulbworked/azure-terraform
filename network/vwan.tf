# Create the main operations networking resource group
resource "azurerm_resource_group" "vwan-rg" {
  name     = "rg-vwan"
  location = "North Europe"

  tags = local.tags
}

###############################################################
#                           VWAN                              #
###############################################################


# Create a VWAN
resource "azurerm_virtual_wan" "vwan-prod-ne" {
  name                              = "vwan-pab-prod-ne"
  resource_group_name               = azurerm_resource_group.vwan-rg.name
  location                          = "North Europe"
  type                              = "Standard"
  disable_vpn_encryption            = false
  allow_branch_to_branch_traffic    = true
  office365_local_breakout_category = "None"

  tags = local.tags
}

# Create a VWAN Hub
resource "azurerm_virtual_hub" "vwan-hub-prod-ne" {
  name                = "vhub-pab-prod-ne"
  resource_group_name = azurerm_resource_group.vwan-rg.name
  location            = "North Europe"
  virtual_wan_id      = azurerm_virtual_wan.vwan-prod-ne.id
  # sanitised
  address_prefix = "0.0.0.0/0"

  tags = local.tags
}

# Hub to VNET connection for Ops 
resource "azurerm_virtual_hub_connection" "hubne-vnetopsne" {
  name                      = "peer-hubne-vnetopsne"
  virtual_hub_id            = azurerm_virtual_hub.vwan-hub-prod-ne.id
  remote_virtual_network_id = azurerm_virtual_network.operations-vnet.id
  internet_security_enabled = true

}

###############################################################
#                    Point to Site VPN Gateway                #
###############################################################

# Create P2S VPN Server Gateway Configuration
resource "azurerm_vpn_server_configuration" "vwan-vpngc-p2s01-prod-ne" {
  name                     = "vpngc-p2s-pab-vpn-01"
  resource_group_name      = azurerm_resource_group.vwan-rg.name
  location                 = "North Europe"
  vpn_authentication_types = ["AAD"]
  vpn_protocols            = ["OpenVPN"]
  # sanitised
  azure_active_directory_authentication {
    audience = "00000000-0000-0000-0000-000000000000"
    issuer   = "https://sts.windows.net/00000000-0000-0000-0000-000000000000/"
    tenant   = "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000"
  }

  tags = local.tags

}

# Create P2S VPN Gateway
resource "azurerm_point_to_site_vpn_gateway" "vwan-vpng-p2s-prod-ne" {
  name                        = "vpng-p2s-pab-prod-ne"
  resource_group_name         = azurerm_resource_group.vwan-rg.name
  location                    = "North Europe"
  virtual_hub_id              = azurerm_virtual_hub.vwan-hub-prod-ne.id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.vwan-vpngc-p2s01-prod-ne.id
  scale_unit                  = 1
  # sanitised
  dns_servers = ["0.0.0.0", "0.0.0.0"]

  connection_configuration {
    name = "DefaultAddressPool"

    # sanitised
    vpn_client_address_pool {
      address_prefixes = ["0.0.0.0/0"]
    }

  }

  tags = local.tags
}

###############################################################
#                   Site to Site VPN Gateway                  #
###############################################################

resource "azurerm_vpn_gateway" "vwan-vpng-s2s-prod-ne" {
  name                = "vpng-s2s-pab-prod-ne"
  resource_group_name = azurerm_resource_group.vwan-rg.name
  location            = "North Europe"
  virtual_hub_id      = azurerm_virtual_hub.vwan-hub-prod-ne.id
  scale_unit          = 1

  bgp_settings {
    asn         = 65515
    peer_weight = 0

    # sanitised
    instance_0_bgp_peering_address {
      custom_ips = ["0.0.0.0"]
    }

    # sanitised
    instance_1_bgp_peering_address {
      custom_ips = ["0.0.0.0"]
    }
  }

  tags = local.tags
}

# ###############################################################
# #                   Site to Site VPN Site                     #
# ###############################################################

resource "azurerm_vpn_site" "vpns-aws-prod-ne" {
  name                = "vpns-aws-pab-prod-ne"
  resource_group_name = azurerm_resource_group.vwan-rg.name
  location            = "North Europe"
  virtual_wan_id      = azurerm_virtual_wan.vwan-prod-ne.id

  address_cidrs = local.aws_cidrs

  link {
    name       = "aws-tunnel-1"
    ip_address = var.aws_vpn_tunnel1_ip
    bgp {
      asn = 64512
      # sanitised
      peering_address = "0.0.0.0"
    }
  }

  link {
    name       = "aws-tunnel-2"
    ip_address = var.aws_vpn_tunnel2_ip
    bgp {
      asn = 64512
      # sanitised
      peering_address = "0.0.0.0"
    }
  }

  tags = local.tags
}

###############################################################
#                   Site to Site VPN Connection               #
###############################################################

# This is the site to site connection required for S2S between Azure and AWS

resource "azurerm_vpn_gateway_connection" "vpnc-aws-prod-ne" {
  name               = "vpnc-aws-pab-prod-ne"
  vpn_gateway_id     = azurerm_vpn_gateway.vwan-vpng-s2s-prod-ne.id
  remote_vpn_site_id = azurerm_vpn_site.vpns-aws-prod-ne.id

  vpn_link {
    name                = "aws-tunnel-1"
    vpn_site_link_id    = azurerm_vpn_site.vpns-aws-prod-ne.link[0].id
    bgp_enabled         = true
    shared_key          = var.aws_vpn_tunnel1_preshared_key
    protocol            = "IKEv2"
    dpd_timeout_seconds = 45

    custom_bgp_address {
      # sanitised
      ip_address          = "0.0.0.0"
      ip_configuration_id = azurerm_vpn_gateway.vwan-vpng-s2s-prod-ne.bgp_settings[0].instance_0_bgp_peering_address[0].ip_configuration_id
    }

    custom_bgp_address {
      # sanitised
      ip_address          = "0.0.0.0"
      ip_configuration_id = azurerm_vpn_gateway.vwan-vpng-s2s-prod-ne.bgp_settings[0].instance_1_bgp_peering_address[0].ip_configuration_id
    }

    ipsec_policy {
      encryption_algorithm     = "GCMAES256"
      integrity_algorithm      = "GCMAES256"
      ike_encryption_algorithm = "GCMAES256"
      ike_integrity_algorithm  = "SHA384"
      dh_group                 = "ECP384"
      pfs_group                = "ECP384"
      sa_lifetime_sec          = 3600
      sa_data_size_kb          = 102400000
    }
  }

  vpn_link {
    name                = "aws-tunnel-2"
    vpn_site_link_id    = azurerm_vpn_site.vpns-aws-prod-ne.link[1].id
    bgp_enabled         = true
    shared_key          = var.aws_vpn_tunnel2_preshared_key
    protocol            = "IKEv2"
    dpd_timeout_seconds = 45

    custom_bgp_address {
      # sanitised
      ip_address          = "0.0.0.0"
      ip_configuration_id = azurerm_vpn_gateway.vwan-vpng-s2s-prod-ne.bgp_settings[0].instance_0_bgp_peering_address[0].ip_configuration_id
    }

    custom_bgp_address {
      # sanitised
      ip_address          = "0.0.0.0"
      ip_configuration_id = azurerm_vpn_gateway.vwan-vpng-s2s-prod-ne.bgp_settings[0].instance_1_bgp_peering_address[0].ip_configuration_id
    }

    ipsec_policy {
      encryption_algorithm     = "GCMAES256"
      integrity_algorithm      = "GCMAES256"
      ike_encryption_algorithm = "GCMAES256"
      ike_integrity_algorithm  = "SHA384"
      dh_group                 = "ECP384"
      pfs_group                = "ECP384"
      sa_lifetime_sec          = 3600
      sa_data_size_kb          = 102400000
    }
  }

  lifecycle {
    ignore_changes = [
      vpn_link
    ]
  }

}

###############################################################
#                   Secure HUB & Firewall                     #
###############################################################

# Create Azure Firewall Policy
resource "azurerm_firewall_policy" "vwan-afwp-prod-ne" {
  name                     = "afwp-pab-prod-ne"
  resource_group_name      = azurerm_resource_group.vwan-rg.name
  location                 = "North Europe"
  sku                      = "Standard"
  threat_intelligence_mode = "Deny"

  dns {
    servers = []

  }

  tags = local.tags
}

# Rule collection group and policies for OPRA
resource "azurerm_firewall_policy_rule_collection_group" "vwan-afpg-opra" {
  name               = "afpg-dnat"
  firewall_policy_id = azurerm_firewall_policy.vwan-afwp-prod-ne.id
  priority           = 100

  nat_rule_collection {
    name     = "dnat-example"
    priority = 100
    action   = "Dnat"

    rule {
      name      = "dnat-opra-dev80"
      protocols = ["TCP"]
      # sanitised
      source_ip_groups = [local.ipg_example]
      # sanitised
      destination_address = "0.0.0.0"
      destination_ports   = ["80"]
      # sanitised
      translated_address = local.dnat_example
      translated_port    = "80"
    }
    rule {
      name      = "dnat-opra-dev443"
      protocols = ["TCP"]
      # sanitised
      source_ip_groups = [local.ipg_example]
      # sanitised
      destination_address = "0.0.0.0"
      destination_ports   = ["443"]
      # sanitised
      translated_address = local.dnat_example
      translated_port    = "443"
    }

  }

}

# Rule collection group and policies for sftp traffic
resource "azurerm_firewall_policy_rule_collection_group" "vwan-afpg-sftp" {
  name               = "afpg-sftp"
  firewall_policy_id = azurerm_firewall_policy.vwan-afwp-prod-ne.id
  priority           = 105

  nat_rule_collection {
    name     = "dnat-sftp"
    priority = 120
    action   = "Dnat"

    rule {
      name      = "dnat-sftp-np"
      protocols = ["TCP"]
      # sanitised
      source_ip_groups = [local.ipg_sftp]
      # sanitised
      destination_address = "0.0.0.0"
      destination_ports   = ["22"]
      # sanitised
      translated_address = "0.0.0.0"
      translated_port    = "22"
    }

    rule {
      name      = "dnat-sftp-prod"
      protocols = ["TCP"]
      # sanitised
      source_ip_groups = [local.ipg_sftp]
      # sanitised
      destination_address = "0.0.0.0"
      destination_ports   = ["22"]
      # sanitised
      translated_address = "0.0.0.0"
      translated_port    = "22"
    }

  }
}


# Rule collection group and policies for general traffic
resource "azurerm_firewall_policy_rule_collection_group" "vwan-afpg-general" {
  name               = "afpg-network"
  firewall_policy_id = azurerm_firewall_policy.vwan-afwp-prod-ne.id
  priority           = 110

  network_rule_collection {
    name     = "protocols"
    priority = 110
    action   = "Allow"

    # Default Rule for UDP & TCP
    rule {
      name      = "Default Protocols"
      protocols = ["UDP", "TCP"]
      # sanitised
      source_addresses      = ["0.0.0.0/0"]
      destination_addresses = ["*"]
      # sanitised but left DNS port in for context
      destination_ports = ["53"]
    }
  }

  application_rule_collection {
    name     = "applications"
    priority = 115
    action   = "Allow"

    rule {
      name = "allow_http_https"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      # sanitised
      source_addresses      = ["0.0.0.0/0"]
      destination_fqdns     = ["*"]
      destination_addresses = ["*"]
    }
  }

  network_rule_collection {
    name     = "network_general"
    priority = 130
    action   = "Allow"

    # Allow Containers access to all (the terraform agent sits in here)
    rule {
      name      = "containers"
      protocols = ["Any"]
      # sanitised
      source_addresses      = ["0.0.0.0/0"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }

    # PointToSite VPN Rule
    rule {
      name      = "point2site_VPN"
      protocols = ["Any"]
      # sanitised
      source_addresses = ["0.0.0.0/0"]
      # sanitised
      destination_ip_groups = [local.ipg_int, local.ipg_vm]
      destination_ports     = ["*"]

    }
  }

  network_rule_collection {
    name     = "network_aws"
    priority = 140
    action   = "Allow"

    # Allow traffic between Azure and AWS VPCs over S2S tunnel
    rule {
      name      = "azure_to_aws"
      protocols = ["Any"]
      # sanitised
      source_addresses = ["0.0.0.0/0"]
      # sanitised
      destination_addresses = local.aws_cidrs
      destination_ports     = ["*"]
    }

    rule {
      name      = "aws_to_azure"
      protocols = ["Any"]
      # sanitised
      source_addresses = local.aws_cidrs
      # sanitised
      destination_addresses = ["0.0.0.0/0"]
      destination_ports     = ["*"]
    }
  }

  network_rule_collection {
    name     = "network_other"
    priority = 150
    action   = "Allow"

    # Allow internal networking 
    rule {
      name      = "internal_nonprod"
      protocols = ["Any"]
      # sanitised
      source_ip_groups      = [local.ipg_int]
      destination_ip_groups = [local.ipg_int]
      destination_ports     = ["*"]
    }
  }

}

###############################################################
#                   Secure HUB Firewall                       #
###############################################################

# Create Secure Hub Azure Firewall
resource "azurerm_firewall" "vwan-azfw-prod-ne" {
  name                = "azfw-pab-prod-ne"
  resource_group_name = azurerm_resource_group.vwan-rg.name
  location            = "North Europe"
  sku_tier            = "Standard"
  sku_name            = "AZFW_Hub"
  firewall_policy_id  = azurerm_firewall_policy.vwan-afwp-prod-ne.id
  virtual_hub {
    virtual_hub_id = azurerm_virtual_hub.vwan-hub-prod-ne.id
    # sanitised
    public_ip_count = xxx
  }

  tags = local.tags
}

# Apply VWAN Hub routing intent (used for routing traffic via Secure Hub)
resource "azurerm_virtual_hub_routing_intent" "vwan-hub-prod-ne-rt" {
  name           = "vwan-hub-prod-net-routingintent"
  virtual_hub_id = azurerm_virtual_hub.vwan-hub-prod-ne.id

  routing_policy {
    name         = "all_traffic"
    destinations = ["PrivateTraffic", "Internet"]
    next_hop     = azurerm_firewall.vwan-azfw-prod-ne.id
  }

}

###############################################################
#                   Logging for VWAN & Firewall               #
###############################################################

# Create Log Analytics Workspace for VWAN/Hub logs
resource "azurerm_log_analytics_workspace" "vwan-law-prod-ne" {
  name                       = "law-vwan-pab-ne"
  resource_group_name        = azurerm_resource_group.vwan-rg.name
  location                   = "North Europe"
  sku                        = "PerGB2018"
  retention_in_days          = 30
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = local.tags
}

# Set up diagnostics for P2S VPN Gateway
resource "azurerm_monitor_diagnostic_setting" "vwan-vpng-p2s-pro-ne-law" {
  name                           = "P2S-Diagnostics"
  target_resource_id             = azurerm_point_to_site_vpn_gateway.vwan-vpng-p2s-prod-ne.id
  log_analytics_workspace_id     = local.law_sentinel_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "GatewayDiagnosticLog"
  }

  enabled_log {
    category = "IKEDiagnosticLog"
  }

  enabled_log {
    category = "P2SDiagnosticLog"
  }

  enabled_mepabc {
    category = "AllMepabcs"
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }

}

# Set up diagnostics for AZ Firewall
resource "azurerm_monitor_diagnostic_setting" "vwan-azfw-pro-ne-law" {
  name                           = "AZFW-Diagnostics"
  target_resource_id             = azurerm_firewall.vwan-azfw-prod-ne.id
  log_analytics_workspace_id     = local.law_sentinel_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AZFWApplicationRule"
  }

  enabled_log {
    category = "AZFWApplicationRuleAggregation"
  }

  enabled_log {
    category = "AZFWDnsQuery"
  }

  enabled_log {
    category = "AZFWFatFlow"
  }

  enabled_log {
    category = "AZFWFlowTrace"
  }

  enabled_log {
    category = "AZFWFqdnResolveFailure"
  }

  enabled_log {
    category = "AZFWIdpsSignature"
  }

  enabled_log {
    category = "AZFWNatRule"
  }

  enabled_log {
    category = "AZFWNatRuleAggregation"
  }

  enabled_log {
    category = "AZFWNetworkRule"
  }

  enabled_log {
    category = "AZFWNetworkRuleAggregation"
  }

  enabled_log {
    category = "AZFWThreatIntel"
  }

  enabled_log {
    category = "AZFWDnsAdditional"
  }

  enabled_mepabc {
    category = "AllMepabcs"
  }

}

resource "azurerm_monitor_diagnostic_setting" "vwan-vpng-s2s-prod-ne-law" {
  name                           = "S2S-Diagnostics"
  target_resource_id             = azurerm_vpn_gateway.vwan-vpng-s2s-prod-ne.id
  log_analytics_workspace_id     = local.law_sentinel_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "GatewayDiagnosticLog"
  }

  enabled_log {
    category = "IKEDiagnosticLog"
  }

  enabled_log {
    category = "RouteDiagnosticLog"
  }

  enabled_log {
    category = "TunnelDiagnosticLog"
  }

  enabled_mepabc {
    category = "AllMepabcs"
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }

}
