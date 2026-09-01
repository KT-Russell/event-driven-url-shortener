# Trust Policy
data "aws_iam_policy_document" "github_tf_deploy_trust" {
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

# Terraform Deploy role
resource "aws_iam_role" "github_tf_deploy" {
  name               = "GitHub-Terraform-Deploy-Role"
  assume_role_policy = data.aws_iam_policy_document.github_tf_deploy_trust.json

  tags = var.tags
}

data "aws_iam_policy_document" "github_tf_deploy" {
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
    sid = "ManageTerraformState"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
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

  # VPC, subnets, routing, security groups and VPC endpoints
  statement {
    sid = "ManageNetworking"

    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:ModifySubnetAttribute",
      "ec2:CreateInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateSecurityGroupRule",
      "ec2:ModifySecurityGroupRules",
      "ec2:CreateVpcEndpoint",
      "ec2:ModifyVpcEndpoint",
      "ec2:DeleteVpcEndpoints",
      "ec2:CreateTags",
      "ec2:DeleteTags",

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
      "ec2:DescribeVpcs"
    ]

    resources = ["*"]
  }

  # ECS cluster, task definitions and services
  statement {
    sid = "ManageECS"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeleteCluster",
      "ecs:PutClusterCapacityProviders",
      "ecs:CreateService",
      "ecs:UpdateService",
      "ecs:DeleteService",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:TagResource",
      "ecs:UntagResource",

      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:ListAccountSettings",
      "ecs:ListAttributes",
      "ecs:ListServices",
      "ecs:ListTagsForResource",
      "ecs:ListTaskDefinitions",
      "ecs:ListTasks"
    ]

    resources = ["*"]
  }

  # Application Load Balancer, listeners and target groups
  statement {
    sid = "ManageLoadBalancing"

    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetWebACL",

      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerAttributes",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth"
    ]

    resources = ["*"]
  }

  # PostgreSQL RDS
  statement {
    sid = "ManageRDS"

    actions = [
      "rds:CreateDBInstance",
      "rds:ModifyDBInstance",
      "rds:DeleteDBInstance",
      "rds:CreateDBSubnetGroup",
      "rds:ModifyDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource",
      "rds:DescribeDBInstances",
      "rds:DescribeDBSubnetGroups",
      "rds:ListTagsForResource"
    ]

    resources = ["*"]
  }

  statement {
  sid = "ManageRDSManagedSecret"

  actions = [
    "secretsmanager:CreateSecret",
    "secretsmanager:TagResource",
  ]

  resources = ["*"]
}
  statement {
    sid = "UseRDSManagedSecretKMS"

    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }

  # Redis / ElastiCache
  statement {
    sid = "ManageElastiCache"

    actions = [
      "elasticache:CreateReplicationGroup",
      "elasticache:ModifyReplicationGroup",
      "elasticache:DeleteReplicationGroup",
      "elasticache:CreateCacheSubnetGroup",
      "elasticache:ModifyCacheSubnetGroup",
      "elasticache:DeleteCacheSubnetGroup",
      "elasticache:AddTagsToResource",
      "elasticache:RemoveTagsFromResource",
      "elasticache:DescribeCacheClusters",
      "elasticache:DescribeCacheSubnetGroups",
      "elasticache:DescribeReplicationGroups",
      "elasticache:ListTagsForResource"
    ]

    resources = ["*"]
  }

  # SQS queues and DLQ
  statement {
    sid = "ManageSQS"

    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
      "sqs:UntagQueue",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags"
    ]

    resources = ["*"]
  }

  # CloudWatch log groups
  statement {
    sid = "ManageCloudWatchLogs"

    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "logs:DeleteRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:ListTagsForResource"
    ]

    resources = ["*"]
  }

  # CloudWatch alarms
  statement {
    sid = "ManageCloudWatch"

    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListTagsForResource"
    ]

    resources = ["*"]
  }

  # SNS alerting
  statement {
    sid = "ManageSNS"

    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:SetTopicAttributes",
      "sns:TagResource",
      "sns:UntagResource",
      "sns:GetTopicAttributes",
      "sns:GetSubscriptionAttributes",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTagsForResource"
    ]

    resources = ["*"]
  }

  # ACM certificate
  statement {
    sid = "ManageACM"

    actions = [
      "acm:RequestCertificate",
      "acm:DeleteCertificate",
      "acm:AddTagsToCertificate",
      "acm:RemoveTagsFromCertificate",
      "acm:DescribeCertificate",
      "acm:ListTagsForCertificate"
    ]

    resources = ["*"]
  }

  # AWS WAF
  statement {
    sid = "ManageWAF"

    actions = [
      "wafv2:CreateWebACL",
      "wafv2:UpdateWebACL",
      "wafv2:DeleteWebACL",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "wafv2:TagResource",
      "wafv2:UntagResource",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:ListTagsForResource",
      "wafv2:ListAvailableManagedRuleGroups"
    ]

    resources = ["*"]
  }

  # ECS service autoscaling
  statement {
    sid = "ManageApplicationAutoScaling"

    actions = [
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:ListTagsForResource",
      "application-autoscaling:TagResource",
      "application-autoscaling:UntagResource",
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingActivities",
      "application-autoscaling:DescribeScalingPolicies"
    ]

    resources = ["*"]
  }

  # Terraform needs metadata about the RDS-managed secret.
  # It does NOT need permission to retrieve the secret value.
  statement {
    sid = "ReadSecretsMetadata"

    actions = [
      "secretsmanager:DescribeSecret"
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadPersistentECR"

    actions = [
      "ecr:DescribeRepositories",
      "ecr:ListTagsForResource"
    ]

    resources = ["*"]
  }

  statement {
    sid = "ReadCallerIdentity"

    actions = [
      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }


  # Manage only the IAM roles used by the dev ECS platform.
  statement {
    sid = "ManageECSIAMRoles"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:GetRole",
      "iam:ListRoleTags",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
    ]

    resources = [
      "arn:aws:iam::*:role/shorturl-dev-*",
    ]
  }

  # Manage inline policies belonging only to the project's ECS roles.
  statement {
    sid = "ManageECSInlinePolicies"

    actions = [
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
    ]

    resources = [
      "arn:aws:iam::*:role/shorturl-dev-*",
    ]
  }

  # Attach/detach the AWS-managed ECS task execution policy only
  # to this project's roles.
  statement {
    sid = "ManageECSManagedPolicyAttachments"

    actions = [
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
    ]

    resources = [
      "arn:aws:iam::*:role/shorturl-dev-*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "iam:PolicyARN"
      values = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
      ]
    }
  }

  # ECS may receive only this project's roles.
  statement {
    sid = "PassECSRoles"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "arn:aws:iam::*:role/shorturl-dev-*",
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "ecs-tasks.amazonaws.com",
      ]
    }
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

# Attach the Deploy permissions policy to the Deploy role

resource "aws_iam_role_policy" "github_tf_deploy" {
  name   = "GitHub-Terraform-Deploy-Policy"
  role   = aws_iam_role.github_tf_deploy.name
  policy = data.aws_iam_policy_document.github_tf_deploy.json
}

