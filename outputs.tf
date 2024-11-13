output "firewall_policy" {
  description = "contains web application fireqwall policy configuration"
  value       = azurerm_web_application_firewall_policy.this
}
