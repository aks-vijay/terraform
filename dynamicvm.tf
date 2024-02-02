variable "numberofmachines" {
  type = number
  description = "This defines the number of VMs."
  default = 2
}

resource "azurerm_network_interface" "appunterface" {
  count = var.numberofmachines

  name                = "appinterface${count.index}"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.appip[count.index].id
  }

  depends_on = [ azurerm_resource_group.appgrp, azurerm_subnet.subnets, azurerm_public_ip.appip ]
}

resource "azurerm_public_ip" "appip" {

  count = var.numberofmachines
  name                = "appip-${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"

  depends_on = [ azurerm_resource_group.appgrp ]
}

terraform plan -out main.tfplan -var="numberofsubnets=3" -var="numberofmachines=3"
