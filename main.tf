module "rg" {
  source              = "./modules/azurerm_resource_group"
  resource_group_name = "rg-${var.application_name}-${var.environment}"
  location            = var.primary_location
}

module "vnet" {
  source              = "./modules/azurerm_virtual_network"
  vnet_name           = "vnet-${var.application_name}-${var.environment}"
  location            = var.primary_location
  resource_group_name = module.rg.resource_group_name
  address_space       = [var.vnet_address_space]
}

locals {
  subnets = {
    AzureBastionSubnet = cidrsubnet(var.vnet_address_space, 4, 0)
    web                = cidrsubnet(var.vnet_address_space, 2, 1)
    app                = cidrsubnet(var.vnet_address_space, 2, 2)
    data               = cidrsubnet(var.vnet_address_space, 2, 3)
  }
}

module "subnet" {
  for_each            = local.subnets
  source              = "./modules/azurerm_subnet"
  subnet_name         = each.key
  resource_group_name = module.rg.resource_group_name
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = [each.value]
}

module "pip" {
  for_each            = var.vms
  source              = "./modules/azurerm_public_ip"
  pip_name            = "pip-${each.key}-${var.environment}"
  resource_group_name = module.rg.resource_group_name
  location            = module.rg.location
}

module "nic" {
  for_each             = var.vms
  source               = "./modules/azurerm_network_interface"
  nic_name             = "nic-${each.key}-${var.environment}"
  resource_group_name  = module.rg.resource_group_name
  location             = module.rg.location
  subnet_id            = module.subnet[each.value.subnet_name].subnet_id
  public_ip_address_id = module.pip[each.key].pip_id
}


# module "vms" {
#   for_each = var.vms
#   source = "./modules/azurerm_linux_virtual_machine"
#   vm_name = each.key
#   resource_group_name = module.rg.resource_group_name
#   location = module.rg.location
#   vm_size = each.value.vm_size
#   admin_username = each.value.admin_username
#   network_interface_ids = []
#   ssh_public_key = 
#   os_disk = each.value.os_disk
#   source_image_reference = each.value.source_image_reference
# }
