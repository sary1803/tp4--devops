
output "public_ip_address" {
  value = azurerm_linux_virtual_machine.main.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.main.private_key_pem
  sensitive = true
}