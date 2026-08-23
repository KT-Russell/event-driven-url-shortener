variable "aws_region" {
  description = "AWS region used for bucket"
  type        = string
  default     = "eu-west-2"
}

variable "state_bucket_name" {
  description = "bucket name"
  type        = string
  default     = "kam-event-driven-url-shortener-tfstate"
}

