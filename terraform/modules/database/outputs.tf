output "endpoint" {
  description = "RDS PostgreSQL endpoint including the port"
  value       = aws_db_instance.main.endpoint
}

output "address" {
  description = "RDS PostgreSQL hostname"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Name of the PostgreSQL database"
  value       = aws_db_instance.main.db_name
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the RDS master credentials"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}