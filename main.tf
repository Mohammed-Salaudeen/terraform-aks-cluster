###backend
terraform {
  backend "azurerm" {
    key                  = "vmss.tfstate"
    container_name       = "mohdsallu"
    storage_account_name = "mohdsallu"
    resource_group_name  = "mohdsallu"
  }
}

##Providers
provider "azurerm" {
  skip_provider_registration = true
  features {}
}
provider "random" {}
provider "kubernetes" {
  config_path    = "~/.kubeconfig"
}

##Variables
variable "name" {
  description = "Enter the value to be used as Input for name argument. e.g. kul/jasse,Ajay,ramya"
}
variable "location" {
  default = "eastus"
}

variable "client_id" {
  description = "Client ID"
}
variable "client_secret" {
  description = "client secret"
}

##Locals 
locals {
  tags = {
    session     = "5"
    environment = "demo"
  }
  name = random_pet.pet.id
}

##Data

##Resources
resource "random_pet" "pet" {}

resource "azurerm_resource_group" "aks" {
  name     = var.name
  location = var.location
  tags     = local.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  resource_group_name    = azurerm_resource_group.aks.name
  name                   = "${local.name}-${var.name}"
  location               = var.location
  kubernetes_version     = "1.29.2"
  dns_prefix             = "${local.name}-${var.name}-k8s"
  local_account_disabled = false
  sku_tier               = "Free"
  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_V2"
    os_disk_size_gb = 30
  }
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
}

resource "local_file" "name" {
    filename = "kubeconfig"
    file_permission = "0600"
    content = azurerm_kubernetes_cluster.aks.kube_config_raw

}


###output