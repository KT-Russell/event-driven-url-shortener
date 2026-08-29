variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type = list(string)
  default = [
    "eu-west-2a",
    "eu-west-2b"
  ]
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "rds_deletion_protection" {
  description = "Protect the RDS instance from accidental deletion"
  type        = bool
  default     = true
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip the final RDS snapshot during deletion"
  type        = bool
  default     = false
}


variable "certificate_domain_name" {
  description = "Fully qualified domain name used by the public ALB"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the project domain"
  type        = string
}

variable "alert_email" {
  description = "Email address used for infrastructure alert notifications"
  type        = string
}

variable "image_tag" {
  description = "Immutable Git commit SHA used to identify application images"
  type        = string
}