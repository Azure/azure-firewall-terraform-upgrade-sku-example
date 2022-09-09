output "link_to_firewall" {
  value = join("/", ["https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource", azurerm_firewall.firewall.id])
}