variable "aws_region" {
  description = "AWS region used for persistent infrastructure"
  type        = string
  default     = "eu-west-2"
}

variable "name_prefix" {
  description = "Prefix used when naming persistent resources"
  type        = string
  default     = "shorturl-dev"
}

variable "tags" {
  description = "Tags applied to persistent infrastructure"
  type        = map(string)

  default = {
    Project     = "event-driven-url-shortener"
    Environment = "persistent"
  }
}
variable "terraform_state_bucket" {
  description = "S3 bucket used for Terraform remote state"
  type        = string
  default     = "kam-event-driven-url-shortener-tfstate"
}

variable "dev_state_key" {
  description = "S3 object key for the dev Terraform state"
  type        = string
  default     = "environments/dev/terraform.tfstate"
}
variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "KT-Russell"
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
  default     = "event-driven-url-shortener"
}