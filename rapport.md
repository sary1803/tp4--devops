# tp4 Devops - Terraform

## Defintion du provider
```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "765266c6-9a23-4638-af32-dd1e32613047"
}
```

## Definition de data

```
data "azurerm_resource_group" "tp4" { 
   name   =   "devops-TP2" 
} 

data "azurerm_virtual_network" "tp4" {
  name = "example-network"
  resource_group_name = data.azurerm_resource_group.tp4.name
}

data "azurerm_subnet" "tp4" {
  name                 = "internal"
  virtual_network_name = data.azurerm_virtual_network.tp4.name
  resource_group_name  = data.azurerm_resource_group.tp4.name
}
```
## creation addresse ip
```
resource "azurerm_network_interface" "main" {
  name                = "devops-20201096"
  location            = data.azurerm_resource_group.tp4.location
  resource_group_name = data.azurerm_resource_group.tp4.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.tp4.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_public_ip" "main" {
  name                = "devops-20201096"
  resource_group_name = data.azurerm_resource_group.tp4.name
  location            = data.azurerm_resource_group.tp4.location
  allocation_method   = "Static"


  tags = {
    environment = "Production"
  }
}
```
## creation ssh-key
```
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
```
## creation machine virtuelle
```
resource "azurerm_linux_virtual_machine" "main" {
  name                = "devops-20201096"
  resource_group_name = "devops-TP2"
  location            = "france central"
  size                = "Standard_D2s_v3"
  admin_username      = "devops"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]


  admin_ssh_key {
    username   = "devops"
    public_key = tls_private_key.main.public_key_openssh
  }

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
}
```
## definition de output pour les informations pour la connection à la machine virtuelle
```

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.main.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.main.private_key_pem
  sensitive = true
}
```
## obtenir les informations
```
terraform output public_ip_address
terraform output -raw tls_private_key > id_rsa
```
## changement des droits du fichier rsa
```
sudo chmod 600 id_rsa   
```
##  commande test 
```
ssh -i id_rsa devops@20.111.12.44 cat /etc/os-release
```