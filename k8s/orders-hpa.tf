resource "kubernetes_horizontal_pod_autoscaler_v2" "orders" {
  metadata {
     name = "orders-hpa" 
     namespace = var.namespace 
  }
  spec {
    scale_target_ref {
      kind        = "Deployment"
      name        = kubernetes_deployment.orders.metadata[0].name
      api_version = "apps/v1"
    }
    min_replicas = 1
    max_replicas = 1
    metric {
      type = "Resource"
      resource { 
        name = "cpu" 
        target { 
            type = "Utilization" 
            average_utilization = 70 
            } 
        }
    }
  }
}
