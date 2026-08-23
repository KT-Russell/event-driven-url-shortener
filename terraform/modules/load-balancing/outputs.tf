output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name assigned to the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arns" {
  description = "Target group ARNs keyed by service name"

  value = {
    for service, target_group in aws_lb_target_group.service :
    service => target_group.arn
  }
}

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer for CloudWatch metric dimensions"
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn_suffixes" {
  description = "Target group ARN suffixes keyed by service name"

  value = {
    for service, target_group in aws_lb_target_group.service :
    service => target_group.arn_suffix
  }
}