resource "azurerm_network_interface_network_security_group_association" "main" {
  network_interface_id          = var.network_interface_id
  application_security_group_id = var.network_interface_id
}
