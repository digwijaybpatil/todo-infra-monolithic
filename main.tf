module "rg" {
  source = "./modules/azurerm_resource_group"
  resource_group_name = "rg-${var.application_name}-${var.environment}"
  location = var.primary_location
}

module "vnet" {
  source = "./modules/azurerm_virtual_network"
  vnet_name = "vnet-${var.application_name}-${var.environment}"
  location = var.primary_location
  resource_group_name = module.rg.resource_group_name
  address_space = [var.vnet_address_space]
}