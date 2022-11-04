provider "azurerm" {
  features {}
}

variable "bookings-app-rg" {
  type    = string
  default = "bookings-app"
}

data "azurerm_resource_group" "bookings-app" {
    name = var.bookings-app-rg
}

output "storage_account" {
  value       = azurerm_storage_account.bookingsapp.name
  description = "Storage Account"
}

output "storage_account_container" {
  value       = azurerm_storage_container.bookingsapp.name
  description = "Storage Account Container"
}