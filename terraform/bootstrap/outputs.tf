output "state_bucket_name" {
  description = "Name of tf remote s3"
  value       = aws_s3_bucket.terraform_state.bucket

}

output "state_bucket_arn" {
  description = "ARN of tf s3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}