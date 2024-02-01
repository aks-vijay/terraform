locals {
  resource_group_name = "app-grp"
  location="East US"

  virtual_network = {
    name = "app-virtualnetwork"
    address_space = "10.0.0.0/16"
  }

  subnets = [
    {
      name = "subnetA", 
      address_prefix="10.0.0.0/24"
    },
    {
      name="subnetB", 
      address_prefix="10.0.1.0/24"
    }
  ]
}

resource "azurerm_resource_group" "appgrp" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "appnetwork" {
  name                = local.virtual_network.name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]
  depends_on = [ azurerm_resource_group.appgrp ]
}

resource "azurerm_subnet" "subnetA" {
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[0].address_prefix]
  depends_on = [ azurerm_virtual_network.appnetwork ]
}

resource "azurerm_subnet" "subnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[1].address_prefix]
  depends_on = [ azurerm_virtual_network.appnetwork ]
}

resource "azurerm_network_interface" "appinterface" {
  name                = "appinterface"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.app-ip.id
  }

  depends_on = [ azurerm_subnet.subnetA]
}


resource "azurerm_public_ip" "app-ip" {
  name                = "app-ip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"

  depends_on = [ azurerm_resource_group.appgrp ]
}

resource "azurerm_network_security_group" "app-nsg" {
  name                = "app-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [ azurerm_resource_group.appgrp ]
}

resource "azurerm_subnet_network_security_group_association" "appnsgass" {
  subnet_id                 = azurerm_subnet.subnetA.id
  network_security_group_id = azurerm_network_security_group.app-nsg.id

  depends_on = [ azurerm_subnet.subnetA, azurerm_network_security_group.app-nsg ]
}

resource "azurerm_windows_virtual_machine" "azvm" {
  name                = "az-vm"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_Ds1_v2"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
  network_interface_ids = [
    azurerm_network_interface.appinterface.id, azurerm_network_interface.secondaryinterface.id
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

  depends_on = [ azurerm_resource_group.appgrp, azurerm_network_interface.appinterface, azurerm_network_interface.secondaryinterface ]
}

resource "azurerm_network_interface" "secondaryinterface" {
  name                = "secondaryinterface"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [ azurerm_subnet.subnetA]
}

resource "azurerm_managed_disk" "appdisk" {
  name                 = "appdisk"
  location             = local.location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  depends_on = [ azurerm_resource_group.appgrp ]
  
}

resource "azurerm_virtual_machine_data_disk_attachment" "appdiskattachment" {
  managed_disk_id    = azurerm_managed_disk.appdisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.azvm.id
  lun                = "0"
  caching            = "ReadWrite"

  depends_on = [ azurerm_managed_disk.appdisk, azurerm_windows_virtual_machine.azvm ]
}
