# *Authentication managed with environmental variables pulled from github secrets:
# ARM_TENANT_ID
# ARM_SUBSCRIPTION_ID
# ARM_CLIENT_ID
# ARM_CLIENT_SECRET -- Client Secret from Service Principal

# Create a resource groups
resource "azurerm_resource_group" "rg" {
  name     = "rg-digital-bi-eastus2-nonprod"
  location = var.location
}



# Create Azure Analysis Services
resource "azurerm_analysis_services_server" "analysisserver" {
  name                    = "${var.prefix}aas"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  sku                     = "S0"
  enable_power_bi_service = true
  
  ipv4_firewall_rule {
    name        = "myRule1"
    range_start = "0.0.0.0"
    range_end   = "255.255.255.255"
  }
  
}


# Create Azure Datafactory
resource "azurerm_data_factory" "adf" {
  name                = "${var.prefix}DF"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


#*** Storage account ** will most likely replace with references to existing storage accounts
resource "azurerm_storage_account" "storage" {
  name                     = "${var.prefix}storage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}


# File system
resource "azurerm_storage_data_lake_gen2_filesystem" "filesystem" {
  name               = "filesystem"
  storage_account_id = azurerm_storage_account.storage.id
  #depends_on = [azurerm_role_assignment.role]  # dependency for the role created
}

# Create Server
resource "azurerm_sql_server" "server" {
  name                         = "${var.prefix}server"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "mvpadmin"
  administrator_login_password = "P@$$word1!"

}



#Create Azure SQL DB
resource "azurerm_sql_database" "sqldb" {
  name                = "${var.prefix}sqldb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  server_name         = azurerm_sql_server.server.name

}


# resource "azurerm_mssql_server_extended_auditing_policy" "example" {
#   server_id                               = azurerm_sql_server.server.id
#   storage_endpoint                        = azurerm_storage_account.storage.primary_blob_endpoint
#   storage_account_access_key              = azurerm_storage_account.storage.primary_access_key
#   storage_account_access_key_is_secondary = false
#   retention_in_days                       = 6
# }


#* BELOW IS USED TO CREATE A SYNAPSE POOL, TODD WALKER NOTED WE MAY BE ABLE TO SETUP ONE MANUALLU WITH THE TEAM
/*

#** Setting the role to permit the filestore creation
resource "azurerm_role_assignment" "role" {
	scope                = azurerm_resource_group.rg.id
	role_definition_name = "Storage Blob Data Contributor"
    principal_id         = "0b2df119-bc75-4148-a92d-b1a5c4132a7a"  #** Should be the service Principal on the resource groun and take ObjectID from Kroger to place here
}




# Synapse 
resource "azurerm_synapse_workspace" "workspace" {
  name                                 = "${var.prefix}workspace"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.filesystem.id
  sql_administrator_login              = "kjakah08"
  sql_administrator_login_password     = "123456!"
}

# Firewall rule to allow all ** May want to change before sending to Kroger...
resource "azurerm_synapse_firewall_rule" "example" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.workspace.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}

# 
resource "azurerm_synapse_sql_pool" "synapsepool" {
  name                 = "${var.prefix}sqlpool"
  synapse_workspace_id = azurerm_synapse_workspace.workspace.id
  sku_name             = "DW100c"
  create_mode          = "Default"
  
  timeouts {
    create = "1h"
    delete = "1h"
	update = "1h"
  }
}

*/
