module "rg" {
  source = "./modules/azurerm_resource_group"
  resource_group_name = "rg-${var.application_name}-${var.environment}"
  location = var.primary_location
}