variable "dns_zone_name" {
  type = string
  default = "privatelink.database.windows.net"
}

variable "dns_link_name" {
  type = string
}

variable "private_endpoint_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

variable "sql_server_id" {
  type = string
}

