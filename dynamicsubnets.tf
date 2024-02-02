variable "numberofsubnets" {
  type = number
  description = "This defines the number of subnets"
  default = 2

  validation {
    condition = var.numberofsubnets < 5
    error_message = "The number of subnets must be less than 5."
  }
}

resource "azurerm_virtual_network" "appnetwork" {
  name                = local.virtual_network.name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]
  depends_on = [ azurerm_resource_group.appgrp ]
}

resource "azurerm_subnet" "subnets" {
  count = var.numberofsubnets

  name                 = "subnet${count.index}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
  depends_on = [ azurerm_virtual_network.appnetwork ]
}

resource "azurerm_network_security_group" "appnsg" {
  name                = "appnsg"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 100
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

resource "azurerm_subnet_network_security_group_association" "appnsglink" {
  count = var.numberofsubnets
  subnet_id                 = azurerm_subnet.subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.appnsg.id

  depends_on = [ azurerm_subnet.subnets, azurerm_network_security_group.appnsg ]
}


terraform plan -out main.tfplan -var="numberofsubnets=3"
