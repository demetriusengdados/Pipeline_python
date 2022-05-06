azure resource "azurerm_resource_provider_registration" "example" {
  name = "Microsoft.PolicyInsights"
}

data "azurerm_container_registry" "example" {
  name                = "testacr"
  resource_group_name = "test"
}

output "login_server" {
  value = data.azurerm_container_registry.example.login_server
}

data "azurerm_kubernetes_cluster" "example" {
  name                = "myakscluster"
  resource_group_name = "my-example-resource-group"
}

data "azurerm_app_service_plan" "example" {
  name                = "search-app-service-plan"
  resource_group_name = "search-service"
}

output "app_service_plan_id" {
  value = data.azurerm_app_service_plan.example.id
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "northeurope"
}

resource "azurerm_data_factory" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_data_factory_pipeline" "example" {
  name                = "example"
  resource_group_name = azurerm_resource_group.example.name
  data_factory_name   = azurerm_data_factory.example.name
}

data "azurerm_application_gateway" "example" {
  name                = "existing-app-gateway"
  resource_group_name = "existing-resources"
}

output "id" {
  value = data.azurerm_application_gateway.example.id
}

data "azurerm_data_lake_store" "example" {
  name                = "testdatalake"
  resource_group_name = "testdatalake"
}

output "data_lake_store_id" {
  value = data.azurerm_data_lake_store.example.id
}

data "azurerm_virtual_network_gateway_connection" "example" {
  name                = "production"
  resource_group_name = "networking"
}

output "virtual_network_gateway_connection_id" {
  value = data.azurerm_virtual_network_gateway_connection.example.id
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "northeurope"
}

resource "azurerm_data_factory" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "example" {
  name                  = "example"
  resource_group_name   = azurerm_resource_group.example.name
  data_factory_name     = azurerm_data_factory.example.name
  service_principal_id  = data.azurerm_client_config.current.client_id
  service_principal_key = "exampleKey"
  tenant                = "11111111-1111-1111-1111-111111111111"
  url                   = "https://datalakestoragegen2"
}

resource "azurerm_resource_group" "example" {
  name     = "tfex-datalake-account"
  location = "northeurope"
}

resource "azurerm_data_lake_store" "example" {
  name                = "tfexdatalakestore"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_data_lake_analytics_account" "example" {
  name                = "tfexdatalakeaccount"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  default_store_account_name = azurerm_data_lake_store.example.name
}

data "azurerm_virtual_machine" "example" {
  name                = "example-vm"
  resource_group_name = "example-resources"
}

resource "azurerm_mssql_virtual_machine" "example" {
  virtual_machine_id               = data.azurerm_virtual_machine.example.id
  sql_license_type                 = "PAYG"
  r_services_enabled               = true
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = "Password1234!"
  sql_connectivity_update_username = "sqllogin"

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }
}

resource "azurestack_resource_group" "test" {
  name     = "acceptanceTestResourceGroup1"
  location = "West US"
}

resource "azurestack_virtual_network" "test" {
  name                = "acceptanceTestVirtualNetwork1"
  address_space       = ["10.0.0.0/16"]
  location            = azurestack_resource_group.test.location
  resource_group_name = azurestack_resource_group.test.name
}

resource "azurestack_subnet" "test" {
  name                 = "testsubnet"
  resource_group_name  = azurestack_resource_group.test.name
  virtual_network_name = azurestack_virtual_network.test.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurestack_resource_group" "test" {
  name     = "test"
  location = "West US"
}

resource "azurestack_virtual_network" "test" {
  name                = "test"
  location            = azurestack_resource_group.test.location
  resource_group_name = azurestack_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurestack_subnet" "test" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurestack_resource_group.test.name
  virtual_network_name = azurestack_virtual_network.test.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurestack_local_network_gateway" "onpremise" {
  name                = "onpremise"
  location            = azurestack_resource_group.test.location
  resource_group_name = azurestack_resource_group.test.name
  gateway_address     = "168.62.225.23"
  address_space       = ["10.1.1.0/24"]
}

resource "azurestack_public_ip" "test" {
  name                         = "test"
  location                     = azurestack_resource_group.test.location
  resource_group_name          = azurestack_resource_group.test.name
  public_ip_address_allocation = "Dynamic"
}

resource "azurestack_virtual_network_gateway" "test" {
  name                = "test"
  location            = azurestack_resource_group.test.location
  resource_group_name = azurestack_resource_group.test.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    public_ip_address_id          = azurestack_public_ip.test.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurestack_subnet.test.id
  }
}

resource "azurestack_virtual_network_gateway_connection" "onpremise" {
  name                = "onpremise"
  location            = azurestack_resource_group.test.location
  resource_group_name = azurestack_resource_group.test.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurestack_virtual_network_gateway.test.id
  local_network_gateway_id   = azurestack_local_network_gateway.onpremise.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

resource "azurecaf_naming_convention" "cafrandom_rg" {  
  name    = "aztfmod"
  prefix  = "dev"
  resource_type    = "rg"
  postfix = "001"
  max_length = 23
  convention  = "cafrandom"
}

resource "azurerm_resource_group" "cafrandom" {
  name     = azurecaf_naming_convention.cafrandom_rg.result
  location = "southeastasia"
}


#The provider generates a name using the input parameters and automatically appends a prefix (if defined), 
#a caf prefix (resource type) and postfix (if defined) in addition to a generated padding string based on the selected naming convention.

provider "azurerm" {
  features {}
}

data "azurerm_data_share_dataset_data_lake_gen2" "example" {
  name     = "example-dsdlg2ds"
  share_id = "example-share-id"
}

output "id" {
  value = data.azurerm_data_share_dataset_data_lake_gen2.example.id
}

provider "azurerm" {
  features {}
}

data "azurerm_data_share_dataset_data_lake_gen2" "example" {
  name     = "example-dsdlg2ds"
  share_id = "example-share-id"
}

output "id" {
  value = data.azurerm_data_share_dataset_data_lake_gen2.example.id
}

provider "azurerm" {
  features {}
}

data "azurerm_data_share_dataset_kusto_cluster" "example" {
  name     = "example-dskc"
  share_id = "example-share-id"
}

output "id" {
  value = data.azurerm_data_share_dataset_kusto_cluster.example.id
}

provider "azurerm" {
  features {}
}

data "azurerm_data_share_dataset_kusto_cluster" "example" {
  name     = "example-dskc"
  share_id = "example-share-id"
}

output "id" {
  value = data.azurerm_data_share_dataset_kusto_cluster.example.id
}

data "azurerm_application_gateway" "example" {
  name                = "existing-app-gateway"
  resource_group_name = "existing-resources"
}

output "id" {
  value = data.azurerm_application_gateway.example.id
}

data "azurerm_eventhub_authorization_rule" "test" {
  name                = "test"
  namespace_name      = "${azurerm_eventhub_namespace.test.name}"
  eventhub_name       = "${azurerm_eventhub.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}


data "azurerm_cosmosdb_account" "example" {
  name                = "tfex-cosmosdb-account"
  resource_group_name = "tfex-cosmosdb-account-rg"
}

resource "azurerm_cosmosdb_mongo_database" "example" {
  name                = "tfex-cosmos-mongo-db"
  resource_group_name = data.azurerm_cosmosdb_account.example.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.example.name
  throughput          = 400
}


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_data_share_account" "example" {
  name                = "example-dsa"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_share" "example" {
  name       = "example_ds"
  account_id = azurerm_data_share_account.example.id
  kind       = "CopyBased"
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestr"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "example-sc"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "container"
}

data "azuread_service_principal" "example" {
  display_name = azurerm_data_share_account.example.name
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = data.azuread_service_principal.example.object_id
}

resource "azurerm_data_share_dataset_blob_storage" "example" {
  name           = "example-dsbsds-file"
  data_share_id  = azurerm_data_share.example.id
  container_name = azurerm_storage_container.example.name
  storage_account {
    name                = azurerm_storage_account.example.name
    resource_group_name = azurerm_storage_account.example.resource_group_name
    subscription_id     = "00000000-0000-0000-0000-000000000000"
  }
  file_path = "myfile.txt"
  depends_on = [
    azurerm_role_assignment.example,
  ]
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "northeurope"
}

resource "azurerm_data_factory" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_data_factory_linked_service_postgresql" "example" {
  name                = "example"
  resource_group_name = azurerm_resource_group.example.name
  data_factory_name   = azurerm_data_factory.example.name
  connection_string   = "Host=example;Port=5432;Database=example;UID=example;EncryptionMethod=0;Password=example"
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "northeurope"
}

resource "azurerm_data_factory" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_data_factory_linked_service_synapse" "example" {
  name                = "example"
  resource_group_name = azurerm_resource_group.example.name
  data_factory_name   = azurerm_data_factory.example.name

  connection_string = "Integrated Security=False;Data Source=test;Initial Catalog=test;User ID=test;Password=test"
} 
