resource "azurerm_storage_account" "vmstorage74737473" {
  name                     = "vmstorage74737473"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  depends_on = [ azurerm_resource_group.appgrp ] 
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.vmstorage74737473.name
  container_access_type = "blob"
  depends_on = [ azurerm_storage_account.vmstorage74737473 ]
}

resource "azurerm_storage_blob" "IISConfig" {
  name                   = "IISConfig.ps1"
  storage_account_name   = azurerm_storage_account.vmstorage74737473.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "IISConfig.ps1"

  depends_on = [ azurerm_storage_container.data ]
}


resource "azurerm_virtual_machine_extension" "vmextension" {
  count = var.numberofmachines
  name                 = "vmextension"
  virtual_machine_id   = azurerm_windows_virtual_machine.azvm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
 {
    "fileURIs": ["https://${azurerm_storage_account.vmstorage74737473.name}.blob.core.windows.net/data/IISConfig.ps1"], 
    "commandToExecute":"powershell -ExecutionPolicy Unrestricted  -file IISConfig.ps1"
 }
SETTINGS

}

