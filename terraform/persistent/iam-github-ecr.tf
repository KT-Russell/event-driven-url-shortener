data "aws_iam_policy_document" "github_ecr_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_ecr_push" {
  name               = "GitHub-ECR-Push-Role"
  assume_role_policy = data.aws_iam_policy_document.github_ecr_trust.json

  tags = var.tags
}

# ECR Permissions Policy
data "aws_iam_policy_document" "github_ecr_push" {
  statement {
    sid = "GetECRAuthorizationToken"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    sid = "PushImagesToProjectRepositories"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = [
      module.ecr.repository_arns["api"],
      module.ecr.repository_arns["worker"],
      module.ecr.repository_arns["dashboard"],
    ]
  }

  statement {
    sid = "WriteCurrentImageTag"

    actions = [
      "ssm:PutParameter",
    ]

    resources = [
      aws_ssm_parameter.current_image_tag.arn,
    ]
  }
}

resource "aws_iam_role_policy" "github_ecr_push" {
  name   = "GitHub-ECR-Push-Policy"
  role   = aws_iam_role.github_ecr_push.name
  policy = data.aws_iam_policy_document.github_ecr_push.json
}