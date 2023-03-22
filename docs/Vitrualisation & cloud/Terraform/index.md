# Terraform

Création d'un fichier `main.tf`:

```tf linenums="1"
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

# Le 'Provider' azurem va nous permettre d'intéragir avec Azure
provider "azurerm" {
  features {}
}

resource "random_pet" "rg_name" {
  prefix = "CS2I"
}

resource "azurerm_resource_group" "rg" {
  location = "West Europe"
  name     = random_pet.rg_name.id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "CS2ILG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "CS2ILG"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Demo"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}
```

Initialisation du terraform :

```bash
terraform init
```

Planninfication des changements :

```bash
terraform plan -out main.tfplan
```

Application des modifications :

```bash
terraform apply main.tfplan
```