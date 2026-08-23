output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_execution.arn
}

output "api_task_role_arn" {
  description = "ARN of the API ECS task role"
  value       = aws_iam_role.api_task.arn
}

output "worker_task_role_arn" {
  description = "ARN of the Worker ECS task role"
  value       = aws_iam_role.worker_task.arn
}

output "dashboard_task_role_arn" {
  description = "ARN of the Dashboard ECS task role"
  value       = aws_iam_role.dashboard_task.arn
}