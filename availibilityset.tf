resource "azurerm_availability_set" "appset" {
  name                = "appset"
  location            = local.location
  resource_group_name = local.resource_group_name
  platform_fault_domain_count = 3
  platform_update_domain_count = 3

  depends_on = [ azurerm_resource_group.appgrp ]
  
}

resource "azurerm_windows_virtual_machine" "azvm" {
  count = var.numberofmachines

  name                = "azvm${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_Ds1_v2"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
  availability_set_id = azurerm_availability_set.appset.id
  network_interface_ids = [
    azurerm_network_interface.appinterface[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [ azurerm_resource_group.appgrp, azurerm_network_interface.appinterface ]
}
