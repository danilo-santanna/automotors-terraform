resource "kubernetes_deployment" "customer" {
  metadata { 
    name = "customer-service" 
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector { 
        match_labels = { 
            app = "customer-service" 
          } 
        }
    template {
      metadata { 
        labels = { 
            app = "customer-service" 
          } 
        }
      spec {
        container {
          name  = "customer-service"
          image = var.customer_image

          port { container_port = 8081 }

          env_from { 
            secret_ref { 
                name = kubernetes_secret.db.metadata[0].name 
              } 
            }
        }
      }
    }
  }
}
