terraform {
  backend "s3" {
    bucket         = "automotors-s3"
    key            = "automotors-terraform/k8s/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}
