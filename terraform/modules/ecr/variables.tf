variable "name_prefix" {
  description = "Prefix used when naming ECR repositories"
  type        = string
}

variable "tags" {
  description = "Tags applied to ECR repositories"
  type        = map(string)
  default     = {}
}