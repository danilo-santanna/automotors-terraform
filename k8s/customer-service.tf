resource "kubernetes_service" "customer" {
  metadata {
    name      = "customer-service"
    namespace = var.namespace
  }
  spec {
    selector = { app = "customer-service" }
    port {
      port        = 8081
      target_port = 8081
    }
    type = "ClusterIP"
  }
}
