module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "${var.project}-${var.env}-vpc"
  cidr = var.vpc_cidr
  azs  = var.azs

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                         = "1"
    "kubernetes.io/cluster/${var.cluster_name}"      = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                = "1"
    "kubernetes.io/cluster/${var.cluster_name}"      = "shared"
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}
