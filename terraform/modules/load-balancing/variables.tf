variable "name_prefix" {
  description = "Prefix used for load balancing resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the target groups are created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the internet-facing ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group attached to the Application Load Balancer"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener"
  type        = string
}

variable "tags" {
  description = "Common tags applied to load balancing resources"
  type        = map(string)
  default     = {}
}