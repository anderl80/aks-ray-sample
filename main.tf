resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location                         = azurerm_resource_group.rg.location
  name                             = azurerm_resource_group.rg.name
  resource_group_name              = "rg-aiops-kuberay"
  dns_prefix                       = "dns"
  http_application_routing_enabled = true
    
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "systempool"
    vm_size    = var.system_node_pool_vm_size
    node_count = var.system_node_pool_node_count
    tags = { owner = var.resource_group_owner }
  }

  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }

  network_profile {
    network_plugin    = "azure"
  }

  web_app_routing {
    dns_zone_ids = []
  }
}

resource "null_resource" "wait_for_aks" {
  depends_on = [azurerm_kubernetes_cluster.k8s]

  provisioner "local-exec" {
    command = <<EOT
      max_retries=10
      retries=0
      while [ "$(az aks show --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.k8s.name} --query "provisioningState" -o tsv)" != "Succeeded" ]; do
        if [ $retries -ge $max_retries ]; then
          echo "Max retries exceeded. Exiting..."
          exit 1
        fi
        echo "Waiting for AKS cluster to be fully provisioned... (Attempt: $((retries+1)))"
        retries=$((retries+1))
        sleep 30
      done
    EOT
  }
}

resource "azapi_update_resource" "k8s-default-node-pool-systempool-taint" {
  type        = "Microsoft.ContainerService/managedClusters@2024-09-02-preview"
  resource_id = azurerm_kubernetes_cluster.k8s.id
  body = jsonencode({
    properties = {
      agentPoolProfiles = [
        {
          name = "systempool"
          nodeTaints = ["CriticalAddonsOnly=true:NoSchedule"]
        }
      ]
    }
  })

  depends_on = [null_resource.wait_for_aks]
}

resource "azurerm_kubernetes_cluster_node_pool" "ray_gpu" {
  name                  = "raygpu"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = var.ray_node_pool_vm_size
  node_count            = 1
  auto_scaling_enabled  = true
  min_count             = 1
  max_count             = 3
  node_labels = {
    "ray-node-type" = "head"
  }

  depends_on = [azapi_update_resource.k8s-default-node-pool-systempool-taint]
}

resource "azurerm_kubernetes_cluster_node_pool" "ray_cpu" {
  name                  = "raycpu"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = var.ray_node_pool_vm_size
  node_count            = 1
  auto_scaling_enabled  = true
  min_count             = 1
  max_count             = 3
  node_labels = {
    "ray-node-type" = "worker"
  }

  depends_on = [azapi_update_resource.k8s-default-node-pool-systempool-taint]
}