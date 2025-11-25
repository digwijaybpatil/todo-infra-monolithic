resource "azurerm_mssql_database" "example" {
  name        = var.database_name
  server_id   = var.sql_server_id
  max_size_gb = var.max_size_gb
  sku_name    = var.sku_name
}
