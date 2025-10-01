resource "kubernetes_horizontal_pod_autoscaler_v2" "customer" {
  metadata {
    name = "customer-hpa" 
    namespace = var.namespace
  }
  spec {
    scale_target_ref {
      kind       = "Deployment"
      name       = kubernetes_deployment.customer.metadata[0].name
      api_version= "apps/v1"
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
