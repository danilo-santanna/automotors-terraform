resource "kubernetes_deployment" "vehicles" {
  metadata { 
    name = "vehicles-service" 
    namespace = var.namespace 
  }
  spec {
    replicas = 1
    selector { 
        match_labels = { 
            app = "vehicles-service" 
          } 
        }
    template {
      metadata { 
        labels = { 
            app = "vehicles-service" 
          }  
        }
      spec {
        container {
          name  = "vehicles-service"
          image = var.vehicles_image

          port { container_port = 8082 }
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
