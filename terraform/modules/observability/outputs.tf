output "log_group_names" {
  description = "CloudWatch log group names keyed by service name"

  value = {
    for service, log_group in aws_cloudwatch_log_group.service :
    service => log_group.name
  }
}

output "alerts_topic_arn" {
  description = "ARN of the SNS topic used for infrastructure alerts"
  value       = aws_sns_topic.alerts.arn
}