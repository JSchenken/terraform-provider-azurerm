provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-%d"
  location = "%s"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa%s"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_service_fabric_cluster" "test" {
  name                = "acctest-%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  reliability_level   = "Bronze"
  upgrade_mode        = "Automatic"
  vm_image            = "Windows"
  management_endpoint = "http://example:80"

  diagnostics_config {
    storage_account_name       = azurerm_storage_account.test.name
    protected_account_key_name = "StorageAccountKey1"
    blob_endpoint              = azurerm_storage_account.test.primary_blob_endpoint
    queue_endpoint             = azurerm_storage_account.test.primary_queue_endpoint
	table_endpoint             = azurerm_storage_account.test.primary_table_endpoint
  }

  upgrade_description {
    force_restart                     = true
    health_check_retry_timeout        = "00:00:02"
    health_check_stable_duration      = "00:00:04"
    health_check_wait_duration        = "00:00:06"
    upgrade_domain_timeout            = "00:00:20"
    upgrade_replica_set_check_timeout = "00:00:10"
    upgrade_timeout                   = "00:00:40"
    health_policy {
        max_percent_unhealthy_nodes = 5
        max_percent_unhealthy_applications = 40
    }

    delta_health_policy {
      max_percent_delta_unhealthy_applications         = 20
      max_percent_delta_unhealthy_nodes                = 40
      max_percent_upgrade_domain_delta_unhealthy_nodes = 60

      application_delta_health_policy {
        application_name = "fabric:/System"
        default_service_type_delta_health_policy {
            max_percent_delta_unhealthy_services = 0
        }
      }
    }
  }

  node_type {
    name                 = "first"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 2020
    http_endpoint_port   = 80
  }
}