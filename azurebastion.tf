resource "azurerm_subnet" "bastionsubnet" {
  name                 = "azurebastionsubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = ["10.0.10.0/24"]
  depends_on = [ azurerm_virtual_network.appnetwork ]
}

resource "azurerm_public_ip" "bastionip" {

  name                = "bastionip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku = "Standard"

  depends_on = [ azurerm_resource_group.appgrp, azurerm_subnet.bastionsubnet ]
}

resource "azurerm_bastion_host" "azbastion" {
  name                = "azbastion"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastionsubnet.id
    public_ip_address_id = azurerm_public_ip.bastionip.id
  }
}
