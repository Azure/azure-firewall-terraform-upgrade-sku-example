locals {
  policies = {
    standard = {
      sku = "Standard"
    }
    premium = {
      sku = "Premium"
    }
  }
  application_rule_collections = [{
    name     = "app_rule_collection1"
    priority = 500
    action   = "Deny"
    rules = [{
      name = "app_rule_collection1_rule1"
      protocols = [{
        type = "Http"
        port = 80
        },
        {
          type = "Https"
          port = 443
        }
      ]
      source_addresses  = ["10.0.0.1"]
      destination_fqdns = ["*.microsoft.com"]
    }]
  }]

  network_rule_collections = [{
    name     = "network_rule_collection1"
    priority = 400
    action   = "Deny"
    rules = [{
      name                  = "network_rule_collection1_rule1"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.0.0.1"]
      destination_addresses = ["192.168.1.1", "192.168.1.2"]
      destination_ports     = ["80", "1000-2000"]
    }]
  }]
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = join("-", [var.firewall_name, "vnet"])
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = join("-", [var.firewall_name, "pip"])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "policy" {
  for_each            = local.policies
  name                = join("-", [var.firewall_policy_name, lower(each.value["sku"])])
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = each.value["sku"]
  base_policy_id = try(azurerm_firewall_policy.policy[each.key].base_policy_id)

  dns {
    proxy_enabled = try(azurerm_firewall_policy.policy[each.key].dns.proxy_enabled)
    servers = try(azurerm_firewall_policy.policy[each.key].dns.servers)
  }

  identity {
    type = try(azurerm_firewall_policy.policy[each.key].identity.type)
    identity_ids = try(azurerm_firewall_policy.policy[each.key].identity.identity_ids)
  }

  insights {
    enabled = try(azurerm_firewall_policy.policy[each.key].insights.enabled)
    default_log_analytics_workspace_id = try(azurerm_firewall_policy.policy[each.key].insights.default_log_analytics_workspace_id)
  }

  intrusion_detection {
    mode = try(azurerm_firewall_policy.policy[each.key].intrusion_detection.mode)
    dynamic "signature_overrides" {

    }
    dynamic "traffic_bypass" {
      
    }
    private_ranges = try(azurerm_firewall_policy.policy[each.key].intrusion_detection.private_ranges)
  }

  private_ip_ranges = try(azurerm_firewall_policy.policy[each.key].private_ip_ranges, null)

  auto_learn_private_ranges_enabled = try(azurerm_firewall_policy.policy[each.key].auto_learn_private_ranges_enabled, null)

  threat_intelligence_allow_list = try(azurerm_firewall_policy.policy[each.key].threat_intelligence_allow_list, null)

  threat_intelligence_mode = try(azurerm_firewall_policy.policy[each.key].threat_intelligence_mode, null)

  tls_certificate {

  }

  sql_redirect_allowed = try(azurerm_firewall_policy.policy[each.key].sql_redirect_allowed, null)

  explicity_proxy {

  }
}

resource "azurerm_firewall_policy_rule_collection_group" "rcg" {
  for_each           = local.policies
  name               = join("-", [var.firewall_policy_name, "rcg"])
  firewall_policy_id = azurerm_firewall_policy.policy[each.key].id
  priority           = 500

  dynamic "application_rule_collection" {
    for_each = local.application_rule_collections
    content {
      name     = application_rule_collection.value["name"]
      priority = application_rule_collection.value["priority"]
      action   = application_rule_collection.value["action"]
      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name        = rule.value["name"]
          description = try(rule.value["description"], null)
          dynamic "protocols" {
            for_each = rule.value["protocols"]
            content {
              type = protocols.value["type"]
              port = protocols.value["port"]
            }
          }
          source_addresses  = try(rule.value["source_addresses"], [])
          destination_fqdns = try(rule.value["destination_fqdns"], [])
        }
      }
    }
  }
  dynamic "network_rule_collection" {
    for_each = local.network_rule_collections
    content {
      name     = network_rule_collection.value["name"]
      priority = network_rule_collection.value["priority"]
      action   = network_rule_collection.value["action"]
      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.value["name"]
          protocols             = rule.value["protocols"]
          destination_ports     = rule.value["destination_ports"]
          source_addresses      = try(rule.value["source_addresses"], [])
          source_ip_groups      = try(rule.value["source_ip_groups"], [])
          destination_addresses = try(rule.value["destination_addresses"])
          destination_ip_groups = try(rule.value["destination_ip_groups"], [])
          destination_fqdns     = try(rule.value["destination_fqdns"], [])

        }
      }
    }
  }
  dynamic "nat_rule_collection" {

  }
}

resource "azurerm_firewall" "firewall" {
  name                = "firewall-to-upgrade"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.upgrade_firewall ? "Premium" : "Standard"
  firewall_policy_id  = var.upgrade_firewall ? azurerm_firewall_policy.policy["premium"].id : azurerm_firewall_policy.policy["standard"].id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}