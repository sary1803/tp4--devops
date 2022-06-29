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
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

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