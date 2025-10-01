variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "automotors"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a","us-east-1b"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24","10.0.102.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "cluster_name" {
  type    = string
  default = "automotors-dev-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 1
}

variable "extra_roles_aws_auth" {
  description = "Roles extras com acesso ao cluster (admin)"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
