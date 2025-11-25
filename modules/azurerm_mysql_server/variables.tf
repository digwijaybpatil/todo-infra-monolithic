variable "sql_server_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sql_server_version" {
  type    = string
  default = "12.0"
}

variable "administrator_login" {
  type = string
}

variable "administrator_login_password" {
  type      = string
  sensitive = true
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2"
}

