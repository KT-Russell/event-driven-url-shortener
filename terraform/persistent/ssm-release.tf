resource "aws_ssm_parameter" "current_image_tag" {
  name        = "/shorturl-dev/current-image-tag"
  description = "Latest successfully published application image tag"
  type        = "String"
  value       = var.initial_image_tag

  lifecycle {
    ignore_changes = [value]
  }

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "persistent"
  }
}