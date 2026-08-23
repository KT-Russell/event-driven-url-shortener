data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


# ECS task execution role

resource "aws_iam_role" "ecs_execution" {
  name = "${var.name_prefix}-ecs-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_execution_secrets" {
  statement {
    sid    = "ReadRDSMasterCredential"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      var.database_secret_arn
    ]
  }
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name = "${var.name_prefix}-ecs-execution-secrets"
  role = aws_iam_role.ecs_execution.id

  policy = data.aws_iam_policy_document.ecs_execution_secrets.json
}



# API task role

resource "aws_iam_role" "api_task" {
  name = "${var.name_prefix}-api-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "api_sqs" {
  statement {
    sid    = "SendClickEvents"
    effect = "Allow"

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      var.click_events_queue_arn
    ]
  }
}

resource "aws_iam_role_policy" "api_sqs" {
  name = "${var.name_prefix}-api-sqs"
  role = aws_iam_role.api_task.id

  policy = data.aws_iam_policy_document.api_sqs.json
}

# Worker task role

resource "aws_iam_role" "worker_task" {
  name = "${var.name_prefix}-worker-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "worker_sqs" {
  statement {
    sid    = "ConsumeClickEvents"
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      var.click_events_queue_arn
    ]
  }
}

resource "aws_iam_role_policy" "worker_sqs" {
  name = "${var.name_prefix}-worker-sqs"
  role = aws_iam_role.worker_task.id

  policy = data.aws_iam_policy_document.worker_sqs.json
}


# Dashboard task role

resource "aws_iam_role" "dashboard_task" {
  name = "${var.name_prefix}-dashboard-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = var.tags
}