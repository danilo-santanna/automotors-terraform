variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "project" {
  type        = string
  default     = "automotors"
  description = "Project name prefix"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "private_subnet_ids" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "orders_nlb_name" {
  type    = string
  default = "a8f4a66539dca462aae94b2a06ee133a"
}


