variable "name_prefix" {
  description = "Prefix used for IAM resource names"
  type        = string
}

variable "click_events_queue_arn" {
  description = "ARN of the SQS click events queue"
  type        = string
}

variable "database_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret"
  type        = string
}

variable "tags" {
  description = "Tags applied to IAM resources"
  type        = map(string)
  default     = {}
}