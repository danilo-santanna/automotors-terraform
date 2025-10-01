output "db_endpoint" {
  value = aws_db_instance.postgres.address
}

output "db_port" {
  value = 5432
}

output "db_name" {
  value = var.db_name
}

output "db_username" {
  value = var.db_username
}
