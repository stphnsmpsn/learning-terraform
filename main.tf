###############################################################################
#   _____ _______ ________      __
#  / ____|__   __|  ____\ \    / /	By: Steve Sampson
# | (___    | |  | |__   \ \  / / 	Created: 2021-04-18
#  \___ \   | |  |  __|   \ \/ /  	Last Modified: 2021-04-18
#  ____) |  | |  | |____   \  /   	Description: Learning Teraform
# |_____/   |_|  |______|   \/                                 
#					
###############################################################################

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}


###############################################################################
#			CREATE RESOURCE GROUP(S)
###############################################################################

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}"
  location = "${var.location}"
}

###############################################################################
#   	      CREATE VIRTUAL NETWORK(S), SUBNET(S), AND IP(S)
###############################################################################

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.main.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

###############################################################################
#		       CREATE NETWORK INTERFACE(S)
###############################################################################

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_F2"
  admin_username                  = "${var.admin_user}"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

###############################################################################
#		  ADD AUTHORIZED_KEYS + CHOOSE OS IMAGE
###############################################################################

  admin_ssh_key {
    username = "${var.admin_user}"
    public_key = file("${var.ssh_key_public}")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  provisioner "remote-exec" {
    inline = ["ls"]

    connection {
      host	       = self.public_ip_address
      type         = "ssh"
      user         = "${var.admin_user}"
      private_key  = "${file(var.ssh_key_private)}"
    }
  }


  provisioner "local-exec" {
    command = "ssh-keyscan -H ${self.public_ip_address} >> ~/.ssh/known_hosts "
  }
  
  provisioner "local-exec" {
    command = "ansible-playbook -b -u ${var.admin_user} -i '${self.public_ip_address},' nginx_install.yml"
  }
}


output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.main.public_ip_address}"
}
