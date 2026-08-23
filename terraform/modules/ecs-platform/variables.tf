variable "name_prefix" {
  description = "Prefix used when naming ECS resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the ECS workloads"
  type        = string
}

variable "repository_urls" {
  description = "ECR repository URLs keyed by service name"
  type        = map(string)
}

variable "image_tag" {
  description = "Container image tag used by the ECS task definitions"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the shared ECS task execution role"
  type        = string
}

variable "api_task_role_arn" {
  description = "ARN of the API ECS task role"
  type        = string
}

variable "worker_task_role_arn" {
  description = "ARN of the Worker ECS task role"
  type        = string
}

variable "dashboard_task_role_arn" {
  description = "ARN of the Dashboard ECS task role"
  type        = string
}

variable "database_host" {
  description = "RDS PostgreSQL hostname"
  type        = string
}

variable "database_port" {
  description = "RDS PostgreSQL port"
  type        = number
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "database_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret"
  type        = string
}

variable "redis_host" {
  description = "Primary Redis endpoint hostname"
  type        = string
}

variable "redis_port" {
  description = "Redis port"
  type        = number
}

variable "sqs_queue_url" {
  description = "URL of the click-events SQS queue"
  type        = string
}

variable "log_group_names" {
  description = "CloudWatch log group names keyed by service name"
  type        = map(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by ECS Fargate tasks"
  type        = list(string)
}

variable "api_security_group_id" {
  description = "Security group attached to API ECS tasks"
  type        = string
}

variable "worker_security_group_id" {
  description = "Security group attached to Worker ECS tasks"
  type        = string
}

variable "dashboard_security_group_id" {
  description = "Security group attached to Dashboard ECS tasks"
  type        = string
}

variable "api_target_group_arn" {
  description = "ARN of the ALB target group for the API service"
  type        = string
}

variable "dashboard_target_group_arn" {
  description = "ARN of the ALB target group for the Dashboard service"
  type        = string
}

variable "api_desired_count" {
  description = "Desired number of API tasks"
  type        = number
  default     = 2
}

variable "worker_desired_count" {
  description = "Desired number of Worker tasks"
  type        = number
  default     = 1
}

variable "dashboard_desired_count" {
  description = "Desired number of Dashboard tasks"
  type        = number
  default     = 2
}

variable "sqs_queue_name" {
  description = "Name of the click-events SQS queue used for Worker autoscaling"
  type        = string
}

variable "api_min_capacity" {
  description = "Minimum number of API tasks"
  type        = number
  default     = 2
}

variable "api_max_capacity" {
  description = "Maximum number of API tasks"
  type        = number
  default     = 4
}

variable "worker_min_capacity" {
  description = "Minimum number of Worker tasks"
  type        = number
  default     = 1
}

variable "worker_max_capacity" {
  description = "Maximum number of Worker tasks"
  type        = number
  default     = 5
}

variable "worker_backlog_target" {
  description = "Target number of visible SQS messages per running Worker task"
  type        = number
  default     = 10
}

variable "dashboard_min_capacity" {
  description = "Minimum number of Dashboard tasks"
  type        = number
  default     = 2
}

variable "dashboard_max_capacity" {
  description = "Maximum number of Dashboard tasks"
  type        = number
  default     = 4
}


variable "tags" {
  description = "Common tags applied to ECS resources"
  type        = map(string)
  default     = {}
}