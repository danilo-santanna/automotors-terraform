resource "kubernetes_secret" "mp" {
  metadata {
    name      = "mp-secret"
    namespace = var.namespace
  }

  data = {
    MP_PUBLIC_KEY     = var.mp_public_key
    MP_ACCESS_TOKEN   = var.mp_access_token
    MP_WEBHOOK_SECRET = var.mp_webhook_secret

    PUBLIC_BASE_URL   = var.payment_public_base_url
  }

  type = "Opaque"
}
