output "repository_urls" {
  description = "ECR repository URLs keyed by service name"

  value = {
    for service, repository in aws_ecr_repository.service :
    service => repository.repository_url
  }
}

output "repository_arns" {
  description = "ECR repository ARNs keyed by service name"

  value = {
    for service, repository in aws_ecr_repository.service :
    service => repository.arn
  }
}