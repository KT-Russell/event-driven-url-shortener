resource "cloudflare_dns_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  type    = "CNAME"
  content = var.alb_dns_name
  proxied = false
  ttl     = 300
}