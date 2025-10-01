resource "kubernetes_service" "vehicles" {
  metadata { 
    name = "vehicles-service" 
    namespace = var.namespace 
  }
  spec {
    selector = { app = "vehicles-service" }
    port {
      port        = 8082
      target_port = 8082
    }
    type = "ClusterIP"
  }
}
