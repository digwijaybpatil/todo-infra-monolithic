variable "application_name" {
  type = string
}

variable "primary_location" {
  type = string
}

variable "environment" {
  type = string
}

variable "vnet_address_space" {
  type = string
}

variable "vms" {
  type = map(object({
    vm_size        = string
    admin_username = string
    subnet_name    = string
    os_disk = object({
      caching              = string
      storage_account_type = string
      disk_size_gb         = optional(number)
    })
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}
