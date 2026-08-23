output "domain_name" {
  description = "Application domain name"
  value       = cloudflare_dns_record.app.name
}