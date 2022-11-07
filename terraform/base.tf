provider "azurerm" {
  features {}
}

variable "sqlmi-hostname" {
  type    = string
}

variable "sqlmi-username" {
  type    = string
}

variable "sqlmi-password" {
  type    = string
}

variable "bookings-app-rg" {
  type    = string
  default = "bookings-app"
}

variable "bookings-app-network" {
  type    = string
  default = "dtc-network"
}

variable "bookings-app-subnet" {
  type    = string
  default = "apps"
}

variable "bookings-app-network-rg" {
  type    = string
  default = "bookings-app"
}

data "azurerm_resource_group" "bookings-app" {
  name = var.bookings-app-rg
}

data "azurerm_virtual_network" "bookings-app" {
  name                = var.bookings-app-network
  resource_group_name = var.bookings-app-network-rg
}

data "azurerm_subnet" "app" {
  name                 = var.bookings-app-subnet
  virtual_network_name = var.bookings-app-network
  resource_group_name  = var.bookings-app-network-rg
}

output "storage_account" {
  value       = azurerm_storage_account.bookingsapp.name
  description = "Storage Account"
}

output "storage_account_container" {
  value       = azurerm_storage_container.bookingsapp.name
  description = "Storage Account Container"
}