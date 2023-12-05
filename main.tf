#create resource group
resource "azurerm_resource_group" "emma_RG" {
  name     = var.resource_group
  location = var.location
}

#create Virtual Network
resource "azurerm_virtual_network" "Vnet" {
  name                = var.vitual_network
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.emma_RG.location
  resource_group_name = azurerm_resource_group.emma_RG.name
}

#Create subnet
resource "azurerm_subnet" "my_subnet" {
  name                 = "terra-sub"
  resource_group_name  = azurerm_resource_group.emma_RG.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#create network interface
resource "azurerm_network_interface" "my_nic" {
  name                = var.network_interface
  location            = azurerm_resource_group.emma_RG.location
  resource_group_name = azurerm_resource_group.emma_RG.name

  ip_configuration {
    name                          = "my_config"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#create Virtual machine
resource "azurerm_windows_virtual_machine" "my_vm" {
  name                  = var.virtual_machine
  location              = azurerm_resource_group.emma_RG.location
  resource_group_name   = azurerm_resource_group.emma_RG.name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.my_nic.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

