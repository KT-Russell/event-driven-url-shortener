variable "domain_name" {
  description = "Fully qualified domain name for the application"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the application DNS record"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}