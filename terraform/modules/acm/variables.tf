variable "domain_name" {
  description = "Fully qualified domain name for the ACM certificate"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for DNS validation"
  type        = string
}

variable "tags" {
  description = "Tags applied to the ACM certificate"
  type        = map(string)
  default     = {}
}