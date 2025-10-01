resource "kubernetes_deployment" "orders" {
  metadata { 
    name = "orders-service" 
    namespace = var.namespace 
  }
  spec {
    replicas = 1
    selector { 
      match_labels = { 
        app = "orders-service" 
      } 
    }
    template {
      metadata { 
        labels = { 
          app = "orders-service" 
        } 
      }
      spec {
        container {
          name  = "orders-service"
          image = var.orders_image

          port { container_port = 8083 }

          # DB envs
          env_from { 
            secret_ref { 
              name = kubernetes_secret.db.metadata[0].name 
            } 
          }

          env_from { 
            secret_ref { 
              name = kubernetes_secret.mp.metadata[0].name 
            } 
          }

          env { 
            name = "CUSTOMERS_BASE_URL" 
            value = "http://${kubernetes_service.customer.metadata[0].name}:8081" 
          }
          env { 
            name = "VEHICLES_BASE_URL"  
            value = "http://${kubernetes_service.vehicles.metadata[0].name}:8082" 
          }
          env {
            name  = "PUBLIC_BASE_URL"
            value = var.payment_public_base_url
          }
        }
      }
    }
  }
}
