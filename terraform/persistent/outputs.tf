output "repository_urls" {
  description = "ECR repository URLs keyed by service name"
  value       = module.ecr.repository_urls
}

output "github_ecr_push_role_arn" {
  description = "IAM role ARN used by GitHub Actions to push images to ECR"
  value       = aws_iam_role.github_ecr_push.arn
}

output "github_tf_plan_role_arn" {
  description = "IAM role ARN used by GitHub Actions for Terraform plans"
  value       = aws_iam_role.github_tf_plan.arn
}

output "github_tf_deploy_role_arn" {
  description = "IAM role ARN used by GitHub Actions for Terraform apply and destroy"
  value       = aws_iam_role.github_tf_deploy.arn
}