resource "aws_sqs_queue" "dlq" {
  name = "${var.name_prefix}-click-events-dlq"

  message_retention_seconds = var.dlq_message_retention_seconds

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-click-events-dlq"
  })
}

resource "aws_sqs_queue" "main" {
  name = "${var.name_prefix}-click-events"

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-click-events"
  })
}