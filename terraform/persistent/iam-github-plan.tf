# Terraform Plan role trust policy

data "aws_iam_policy_document" "github_tf_plan_trust" {
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

# Terraform Plan role

resource "aws_iam_role" "github_tf_plan" {
  name               = "GitHub-Terraform-Plan-Role"
  assume_role_policy = data.aws_iam_policy_document.github_tf_plan_trust.json

  tags = var.tags
}

# Terraform Plan permissions

data "aws_iam_policy_document" "github_tf_plan" {
  statement {
    sid = "ListTerraformStatePrefix"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_state_bucket}",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        var.dev_state_key,
        "${var.dev_state_key}.tflock",
      ]
    }
  }

  statement {
    sid = "ReadTerraformState"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_state_bucket}/${var.dev_state_key}",
    ]
  }

  statement {
    sid = "ManageTerraformStateLock"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_state_bucket}/${var.dev_state_key}.tflock",
    ]
  }

  statement {
    sid = "ReadEC2Networking"

    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeManagedPrefixLists",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribePrefixLists",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadECS"

    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:ListAccountSettings",
      "ecs:ListAttributes",
      "ecs:ListServices",
      "ecs:ListTagsForResource",
      "ecs:ListTaskDefinitions",
      "ecs:ListTasks",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadLoadBalancing"

    actions = [
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerAttributes",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadRDS"

    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBSubnetGroups",
      "rds:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadElastiCache"

    actions = [
      "elasticache:DescribeCacheClusters",
      "elasticache:DescribeCacheSubnetGroups",
      "elasticache:DescribeReplicationGroups",
      "elasticache:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadSQS"

    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadECR"

    actions = [
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadCloudWatchLogs"

    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadCloudWatch"

    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadSNS"

    actions = [
      "sns:GetSubscriptionAttributes",
      "sns:GetTopicAttributes",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadIAM"

    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadACM"

    actions = [
      "acm:DescribeCertificate",
      "acm:ListTagsForCertificate",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadWAF"

    actions = [
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadApplicationAutoScaling"

    actions = [
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingActivities",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadSecretsMetadata"

    actions = [
      "secretsmanager:DescribeSecret",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadCallerIdentity"

    actions = [
      "sts:GetCallerIdentity",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadCurrentImageTag"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      aws_ssm_parameter.current_image_tag.arn
    ]
  }
}

# Attach the custom Plan policy to the role

resource "aws_iam_role_policy" "github_tf_plan" {
  name   = "GitHub-Terraform-Plan-Policy"
  role   = aws_iam_role.github_tf_plan.name
  policy = data.aws_iam_policy_document.github_tf_plan.json
}