locals {
  services = toset([
    "api",
    "worker",
    "dashboard",
  ])
}

resource "aws_ecr_repository" "service" {
  for_each = local.services

  name                 = "${var.name_prefix}-${each.key}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}-ecr"
  })
}