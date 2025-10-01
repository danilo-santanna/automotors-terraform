provider "aws" { region = var.aws_region }

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket         = "automotors-s3"
    key            = "automotors-terraform/infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket         = "automotors-s3"
    key            = "postgres-terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}

data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.infra.outputs.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.infra.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
