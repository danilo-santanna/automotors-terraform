variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "image" {
  type    = string
  default = "danilo766/automotors-app:1.1"
}

variable "customer_image" { 
    type = string  
    default = "danilo766/customer-service:1.0" 
}

variable "vehicles_image" { 
    type = string  
    default = "danilo766/vehicles-service:1.2" 
}

variable "orders_image"  { 
    type = string  
    default = "danilo766/orders-service:1.7" 
}


variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_user" {
  type    = string
  default = "postgres"
}

variable "mp_public_key" {
  type      = string
  sensitive = true
}

variable "mp_access_token" {
  type      = string
  sensitive = true
}

variable "mp_webhook_secret" {
  type      = string
  sensitive = true
}

variable "payment_public_base_url" {
  type      = string
}


