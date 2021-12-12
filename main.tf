terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

variable "resourceLocation" {
  default = "Canada East"
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "tfe-resource-group"
  location = var.resourceLocation
  tags = {
    env = "eng"
  }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.resourceLocation
  address_space       = ["10.0.0.0/16"]
  tags = {
    env = "eng"
  }
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = var.resourceLocation
  resource_group_name = azurerm_resource_group.example.name
  tags = {
    env = "eng"
  }

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                            = "example-machine"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = var.resourceLocation
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "Apples123!@#"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  tags = {
    env = "eng"
  }
}

output "resource_group_id" {
  value = azurerm_resource_group.example.name
}
