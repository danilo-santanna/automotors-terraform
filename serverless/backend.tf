data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket       = "automotors-s3"
    key          = "automotors-terraform/infra/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}