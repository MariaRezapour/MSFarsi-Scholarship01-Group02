resource "azurerm_resource_group" "RG" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_service_plan" "ServicePlan01" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  os_type             = "Windows"
  sku_name            = var.sku_name
}

resource "azurerm_windows_web_app" "Webapp01" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  service_plan_id     = azurerm_service_plan.ServicePlan01.id

  site_config {
    always_on = false
  }
}

resource "azurerm_virtual_network" "vnet01" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet1_name
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = var.subnet1_address_prefixes
}

resource "azurerm_subnet" "subnet2" {
  name                 = var.subnet2_name
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = var.subnet2_address_prefixes
}

resource "azurerm_public_ip" "PIP" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = var.allocation_method
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appGW01" {
  name                = var.app_gateway_name
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location

  sku {
    name     = var.gateway_sku_name
    tier     = var.gateway_sku_tier
    capacity = 2
  }

  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.subnet2.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.PIP.id
  }

  backend_address_pool {
    name = var.backend_pool_name
    // fqdns  =  var.web_app_name

  }

  backend_http_settings {
    name                  = var.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    path                  = "/login.html/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.http_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.route_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = var.http_listener_name
    backend_address_pool_name  = var.backend_pool_name
    backend_http_settings_name = var.backend_http_settings_name
  }
}

resource "azurerm_log_analytics_workspace" "workspace01" {
  name                = var.Workspace_Name
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  sku                 = "PerGB2018"
}


resource "azurerm_monitor_diagnostic_setting" "diagnostic" {
  name                       = var.diagnostic_setting_name
  target_resource_id         = azurerm_application_gateway.appGW01.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace01.id
  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true
  }
  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true
  }
  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

