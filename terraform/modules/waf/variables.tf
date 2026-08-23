variable "name_prefix" {
  description = "Prefix used when naming WAF resources"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer protected by WAF"
  type        = string
}

variable "tags" {
  description = "Tags applied to WAF resources"
  type        = map(string)
  default     = {}
}