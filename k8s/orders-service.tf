resource "kubernetes_service" "orders" {
    metadata {
    name      = "orders-service"
    namespace = var.namespace
    annotations = {
        "service.beta.kubernetes.io/aws-load-balancer-type"          = "nlb"
        "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
        "service.beta.kubernetes.io/aws-load-balancer-scheme"        = "internet-facing"
    spec {
        selector = { app = "orders-service" }
        port {
            port        = 80
            target_port = 8083
            node_port   = 32453
        }
        type = "LoadBalancer"
    }
}