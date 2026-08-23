output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "api_task_definition_arn" {
  description = "ARN of the API ECS task definition"
  value       = aws_ecs_task_definition.api.arn
}

output "worker_task_definition_arn" {
  description = "ARN of the Worker ECS task definition"
  value       = aws_ecs_task_definition.worker.arn
}

output "dashboard_task_definition_arn" {
  description = "ARN of the Dashboard ECS task definition"
  value       = aws_ecs_task_definition.dashboard.arn
}

output "api_service_name" {
  description = "Name of the API ECS service"
  value       = aws_ecs_service.api.name
}

output "worker_service_name" {
  description = "Name of the Worker ECS service"
  value       = aws_ecs_service.worker.name
}

output "dashboard_service_name" {
  description = "Name of the Dashboard ECS service"
  value       = aws_ecs_service.dashboard.name
}



