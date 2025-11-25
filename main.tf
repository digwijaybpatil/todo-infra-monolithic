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
  pip_name            = "pip-${each.key}-${var.application_name}-${var.environment}"
  resource_group_name = module.rg.resource_group_name
  location            = module.rg.location
}

module "nic" {
  for_each             = var.vms
  source               = "./modules/azurerm_network_interface"
  nic_name             = "nic-${each.key}-${var.application_name}-${var.environment}"
  resource_group_name  = module.rg.resource_group_name
  location             = module.rg.location
  subnet_id            = module.subnet[each.value.subnet_name].subnet_id
  public_ip_address_id = module.pip[each.key].pip_id
}

module "nsg" {
  for_each            = var.vms
  source              = "./modules/azurerm_network_security_group"
  nsg_name            = "nsg-${each.key}-${var.application_name}-${var.environment}"
  resource_group_name = module.rg.resource_group_name
  location            = module.rg.location
  security_rules      = each.value.security_rules
}

module "nic_nsg_association" {
  for_each                  = var.vms
  source                    = "./modules/azurerm_network_interface_security_group_association"
  network_interface_id      = module.nic[each.key].nic_id
  network_security_group_id = module.nsg[each.key].nsg_id
}

data "azurerm_key_vault" "existing_kv" {
  name                = "kv-digwi-shared"
  resource_group_name = "rg-digwi-shared-kv"
}

data "azurerm_key_vault_secret" "public_ssh_key" {
  name         = "vm-ssh-public-key"
  key_vault_id = data.azurerm_key_vault.existing_kv.id
}


module "vm" {
  for_each               = var.vms
  source                 = "./modules/azurerm_linux_virtual_machine"
  vm_name                = each.key
  resource_group_name    = module.rg.resource_group_name
  location               = module.rg.location
  vm_size                = each.value.vm_size
  admin_username         = each.value.admin_username
  network_interface_ids  = [module.nic[each.key].nic_id]
  ssh_public_key         = data.azurerm_key_vault_secret.public_ssh_key.value
  os_disk                = each.value.os_disk
  source_image_reference = each.value.source_image_reference
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.existing_kv.id
}

module "sql_server" {
  source                       = "./modules/azurerm_mssql_server"
  sql_server_name              = "sqlserver${var.application_name}${var.environment}"
  resource_group_name          = module.rg.resource_group_name
  location                     = module.rg.location
  administrator_login          = "sqladminuser"
  administrator_login_password = data.azurerm_key_vault_secret.sql_admin_password.value
}

module "sql_db" {
  source        = "./modules/azurerm_mssql_database"
  database_name = "sqldb-${var.application_name}-${var.environment}"
  sql_server_id = module.sql_server.sql_server_id
}

module "sql_private_endpoint" {
  source = "./modules/azurerm_private_endpoint_sql"

  resource_group_name = module.rg.resource_group_name
  location            = module.rg.location

  dns_zone_name = "privatelink.database.windows.net"
  dns_link_name = "sql-dns-link-${var.application_name}-${var.environment}"

  virtual_network_id = module.vnet.vnet_id
  subnet_id          = module.subnet["data"].subnet_id  

  private_endpoint_name = "pe-sql-${var.application_name}-${var.environment}"

  sql_server_id = module.sql_server.sql_server_id
}
