terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.89.0"
    }
  }
}

provider "azurerm" {
  subscription_id = ""
  tenant_id = ""
  client_id = ""
  client_secret = ""

  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = "East US"
}

resource "azurerm_storage_account" "appstorage5695" {
  name                     = "appstorage5695"
  resource_group_name      = "app-grp"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  depends_on = [ azurerm_resource_group.appgrp ]
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = "appstorage5695"
  container_access_type = "blob"
  depends_on = [ azurerm_storage_account.appstorage5695 ]
}

resource "azurerm_storage_blob" "maintf" {
  name                   = "main.tf"
  storage_account_name   = "appstorage5695"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "main.tf"
  depends_on = [ azurerm_storage_container.data ]
}
