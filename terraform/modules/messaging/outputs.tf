output "queue_url" {
  description = "URL of the main click-events SQS queue"
  value       = aws_sqs_queue.main.url
}

output "queue_arn" {
  description = "ARN of the main click-events SQS queue"
  value       = aws_sqs_queue.main.arn
}

output "dlq_url" {
  description = "URL of the click-events dead-letter queue"
  value       = aws_sqs_queue.dlq.url
}

output "dlq_arn" {
  description = "ARN of the click-events dead-letter queue"
  value       = aws_sqs_queue.dlq.arn
}
output "queue_name" {
  description = "Name of the main click-events SQS queue"
  value       = aws_sqs_queue.main.name
}