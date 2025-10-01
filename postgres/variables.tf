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

variable "db_name" {
  type    = string
  default = "automotorsdb"
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "engine_ver" {
  type    = string
  default = "8.0"
}
