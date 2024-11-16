variable "resource_group_name" {
  default = "sch-group-2-rg"
}

variable "location" {
  default = "SwedenCentral"
}

variable "service_plan_name" {
  default = "serviceplan01"
}

variable "sku_name" {
  default = "F1"
}

variable "web_app_name" {
  default = "SCHG0211173"
}

variable "vnet_name" {
  default = "Central-SW-SchG02-Dev-Vnet01"
}

variable "vnet_address_space" {
  default = ["10.0.0.0/25"]
}

variable "subnet1_name" {
  default = "Cnetral-SW-SchG02-Sub01"
}

variable "subnet1_address_prefixes" {
  default = ["10.0.0.64/26"]
}

variable "subnet2_name" {
  default = "Central-SW-SchG02-AppGW01-Sub02"
}

variable "subnet2_address_prefixes" {
  default = ["10.0.0.0/26"]
}

variable "public_ip_name" {
  default = "Central-SW--AppGW-Front-PIP"
}

variable "app_gateway_name" {
  default = "Cenrtal-SW-SchG02-AppGW01"
}

variable "frontend_port_name" {
  default = "frontendport"
}

variable "backend_pool_name" {
  default = "BC-pool01"
}

variable "backend_http_settings_name" {
  default = "BackSetting01"
}

variable "http_listener_name" {
  default = "listener01"
}

variable "route_name" {
  default = "route01"
}

variable "gateway_ip_configuration_name" {
  default = "GW-IP"
}

variable "frontend_ip_configuration_name" {
  default = "FrontendIp"
}

variable "gateway_sku_name" {
  default = "WAF_v2"
}

variable "gateway_sku_tier" {
  default = "WAF_v2"
}

variable "allocation_method" { default = "Static" }
variable "app_service_url" {

  description = "URL of the App Service"
  default     = "https://mariasch102.azurewebsites.net/"
}

variable "diagnostic_setting_name" { default = "SW-Central-WebappGW01Diagnostic" }

variable "Workspace_Name" { default = "SW-Central-Workspace01" }
