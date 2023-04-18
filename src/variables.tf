variable "resource_group_name" {
  description = "Name of the resource group to be created"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources in"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "Username for the virtual machine"
  type        = string
}

variable "admin_password" {
  description = "Password for the virtual machine"
  type        = string
  sensitive   = true
}

variable "virtual_network_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "virtual_network_resource_group_name" {
  description = "Name of the resource group containing the existing virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the existing subnet within the virtual network"
  type        = string
}
