terraform {
  backend "s3" {
    bucket         = "automotors-s3"
    key            = "automotors-terraform/infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}
