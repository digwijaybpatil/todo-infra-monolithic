variable "database_name" {
  type = string
}

variable "sql_server_id" {
  type = string
}

variable "max_size_gb" {
  type    = number
  default = 2
}

variable "sku_name" {
  type    = string
  default = "S0"
}
