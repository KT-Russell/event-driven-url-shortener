variable "name_prefix" {
  description = "Prefix used when naming CloudWatch log groups."
  type        = string
}

variable "retention_in_days" {
  description = "Number of days CloudWatch Logs retains application logs."
  type        = number
  default     = 30
}

variable "alert_email" {
  description = "Email address subscribed to infrastructure alerts"
  type        = string
}

variable "alb_arn_suffix" {
  description = "Application Load Balancer ARN suffix for CloudWatch metrics"
  type        = string
}

variable "target_group_arn_suffixes" {
  description = "Target group ARN suffixes keyed by service name"
  type        = map(string)
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_names" {
  description = "ECS service names keyed by service"
  type        = map(string)
}

variable "tags" {
  description = "Tags applied to CloudWatch log groups."
  type        = map(string)
  default     = {}
}