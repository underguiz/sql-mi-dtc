resource "random_string" "bookings-app-password" {
  length           = 16
  special          = true
  upper            = true
  override_special = "!#$%*()-_=+[]{}:?"
}

resource "azurerm_windows_virtual_machine_scale_set" "bookings-app" {
  name                 = "bookings-app"
  resource_group_name  = data.azurerm_resource_group.bookings-app.name
  location             = data.azurerm_resource_group.bookings-app.location
  computer_name_prefix = "app"
  sku                  = "Standard_D4s_v5"
  instances            = 1
  admin_password       = "${random_string.bookings-app-password.result}"
  admin_username       = "bookings-app"
  license_type         = "Windows_Server" 
  zones                = [1, 2, 3]

  custom_data = base64encode(templatefile("config/connectionStrings.config.tpl", { database_fqdn = "${var.sqlmi-hostname}", database_user = "${var.sqlmi-username}", database_password = "${var.sqlmi-password}" }))

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-G2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "primary"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = data.azurerm_subnet.app.id
    }
  }

}

resource "azurerm_virtual_machine_scale_set_extension" "custom-data" {
  name                         = "custom-data"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.bookings-app.id
  publisher                    = "Microsoft.Compute"
  type                         = "CustomScriptExtension"
  type_handler_version         = "1.10"
  protected_settings = jsonencode({
    "commandToExecute" = "Copy-Item C:\\AzureData\\CustomData.bin -Destination C:\\InetPub\\wwwroot\\config\\connectionStrings.config"
  })
}