resource "kubernetes_secret" "db" {
  metadata {
    name      = "db-secret"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL      = "jdbc:postgresql://${data.terraform_remote_state.db.outputs.db_endpoint}:${data.terraform_remote_state.db.outputs.db_port}/${data.terraform_remote_state.db.outputs.db_name}"
    SPRING_DATASOURCE_USERNAME = data.terraform_remote_state.db.outputs.db_username
    SPRING_DATASOURCE_PASSWORD = var.db_password
  }

  type = "Opaque"
}
