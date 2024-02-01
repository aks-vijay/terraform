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

/*

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
    name                       = "AllowSSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
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

resource "tls_private_key" "linuxkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linuxpemkey"{
  filename = "linuxkey.pem"
  content=tls_private_key.linuxkey.private_key_pem
  depends_on = [
    tls_private_key.linuxkey
  ]
}


resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "linuxvm"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "linuxusr"
  network_interface_ids = [
    azurerm_network_interface.appinterface.id
  ]

   admin_ssh_key {
     username="linuxusr"
     public_key = tls_private_key.linuxkey.public_key_openssh
   }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.appinterface,
    azurerm_resource_group.appgrp,
    tls_private_key.linuxkey
    
  ]
}

*/

resource "azurerm_storage_account" "storageaccount3737136" {
  name                     = "storageaccount3737136"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [ azurerm_resource_group.appgrp ]
}

resource "azurerm_storage_container" "storagecontainer73638" {
  count = 3
  name                  = "${count.index}storagecontainer73638"
  storage_account_name  = azurerm_storage_account.storageaccount3737136.name
  container_access_type = "private"
}
