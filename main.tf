resource "azurerm_resource_group" "RG" {
  name     = var.resource_group_name
  location = var.location
    tags = {
     environment = "DevTest"
     ServiceOwner = "Sch-Group2"
     BillingIdentifier = "MSFarsi"
       }
}

resource "azurerm_service_plan" "ServicePlan01" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  os_type             = "Windows"
  sku_name            = var.sku_name
tags = {
    environment = "DevTest"
    ServiceOwner = "Sch-Group2"
   BillingIdentifier = "MSFarsi"
  }
}

resource "azurerm_windows_web_app" "Webapp01" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  service_plan_id     = azurerm_service_plan.ServicePlan01.id

  site_config {
    always_on = false
  

 # Disable public access and restrict to specific VNet (Application Gateway)
    ip_restriction {
          action = "Allow"
          priority = 100
          name = "AllowSpecificIP"
         // type  = "VirtualNetwork"
         virtual_network_subnet_id = azurerm_subnet.subnet2.id
}
ip_restriction {
   action = "Deny"
   priority = 200
   name = "DenyAllPublic"
    ip_address = "0.0.0.0/0"  # Block all public IPs
}
  }
  provisioner "local-exec" {
    command = <<EOT
      # Assuming the HTML file is located at '/home/your-cloud-shell-path/login.html'
      # You can update the path as needed.
      az webapp deployment source config-zip   --name ${var.web_app_name} --resource-group ${var.resource_group_name}  --src /home/maria/bin/html/login.zip  
  EOT
}
tags = {
    environment = "DevTest"
    ServiceOwner = "Sch-Group2"
    BillingIdentifier = "MSFarsi"
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
#WAF Policy
resource "azurerm_web_application_firewall_policy" "AppGWWAF01" {
  name                = "Central-SW-SCHG02-APPGWWAF01"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location

  # Custom rule to block Spain traffic based on IP ranges
  custom_rules {
    name      = "Block-Spain-Traffic"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

   operator           = "GeoMatch"
      match_values       = ["ES"]
    }

    action = "Block"
  }

  # OWASP 3.2 Rule Set and Managed Rules Configuration
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"

      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"

        rule {
          id      = "920300"
          enabled = true
          action  = "Log"  # Example: Set specific OWASP rule to "Log"
        }

        rule {
          id      = "920440"
          enabled = true
          action  = "Block"  # Example: Set specific OWASP rule to "Block"
        }
      }
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"  # Switch to "Detection" for testing before blocking
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }
tags = {
     environment = "DevTest"
     ServiceOwner = "Sch-Group2"
     BillingIdentifier = "MSFarsi"
  }
}




# APP Gateway 
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
    port = 443
  }
 ssl_certificate {
          name = "CertNewApp"
         data = filebase64("CertNewApp.pfx") 
         password = "password"
 }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.PIP.id
  }

  backend_address_pool {
    name = var.backend_pool_name
     fqdns = ["${var.web_app_name}.azurewebsites.net"]
  }

  backend_http_settings {
    name                  = var.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    path                  = "/login.html/"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.http_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Https"
   ssl_certificate_name = "CertNewApp"
  }
   
url_path_map {
 name = "path-map"
 default_backend_address_pool_name = var.backend_pool_name
 default_backend_http_settings_name = var.backend_http_settings_name
 path_rule {
 name = "api-path"
 paths = ["/login.html "]
 backend_address_pool_name = var.backend_pool_name
 backend_http_settings_name = var.backend_http_settings_name
 }
}


equest_routing_rule {
    name                       = var.route_name
    priority                   = 9
    rule_type                  = "PathBasedRouting"
    http_listener_name         = var.http_listener_name
   url_path_map_name           = "api-path"
     backend_address_pool_name  = var.backend_pool_name
     backend_http_settings_name = var.backend_http_settings_name
  }

firewall_policy_id = azurerm_web_application_firewall_policy.AppGWWAF01.id
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

