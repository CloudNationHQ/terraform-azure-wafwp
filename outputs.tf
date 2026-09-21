output "firewall_policy" {
  description = "contains web application firewall policy configuration"
  value       = azurerm_web_application_firewall_policy.this
}
