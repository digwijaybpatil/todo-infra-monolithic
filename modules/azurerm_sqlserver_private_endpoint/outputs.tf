output "private_endpoint_ip" {
  value = azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address
}

output "dns_zone_id" {
  value = azurerm_private_dns_zone.sql_private_dns.id
}
