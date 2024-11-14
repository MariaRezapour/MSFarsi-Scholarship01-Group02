output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.RG.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.RG.location
}

output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = azurerm_service_plan.ServicePlan01.id
}

output "app_service_name" {
  description = "The name of the Windows Web App"
  value       = azurerm_windows_web_app.Webapp01.name
}

output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.vnet01.name
}

output "subnet1_name" {
  description = "The name of the first subnet"
  value       = azurerm_subnet.subnet1.name
}

output "subnet2_name" {
  description = "The name of the second subnet"
  value       = azurerm_subnet.subnet2.name
}

output "public_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = azurerm_public_ip.PIP.ip_address
}

output "application_gateway_name" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.appGW01.name
}

output "frontend_ip_configuration_id" {
  description = "The ID of the frontend IP configuration"
  value       = azurerm_application_gateway.appGW01.frontend_ip_configuration[0].id
}
