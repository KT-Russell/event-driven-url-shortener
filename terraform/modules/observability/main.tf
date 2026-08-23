locals {
  services = toset([
    "api",
    "worker",
    "dashboard",
  ])

  alb_target_services = toset([
    "api",
    "dashboard",
  ])
}

resource "aws_cloudwatch_log_group" "service" {
  for_each = local.services

  name              = "/ecs/${var.name_prefix}/${each.key}"
  retention_in_days = var.retention_in_days

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cloudwatch"
  })
}

resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-alerts"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alerts"
  })
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  alarm_name          = "${var.name_prefix}-alb-target-5xx"
  alarm_description   = "Alarm when ALB targets return HTTP 5xx responses"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  evaluation_periods = 2
  threshold          = 5

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"
  statistic   = "Sum"
  period      = 60

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  for_each = local.alb_target_services

  alarm_name        = "${var.name_prefix}-${each.key}-unhealthy-targets"
  alarm_description = "Alarm when ${each.key} has unhealthy ALB targets"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 1

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Maximum"
  period      = 60

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffixes[each.key]
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_running_below_desired" {
  for_each = var.ecs_service_names

  alarm_name        = "${var.name_prefix}-${each.key}-running-below-desired"
  alarm_description = "Alarm when ECS running task count is below desired task count for ${each.key}"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 0

  metric_query {
    id          = "deviation"
    expression  = "desired - running"
    label       = "Desired tasks minus running tasks"
    return_data = true
  }

  metric_query {
    id          = "running"
    return_data = false

    metric {
      metric_name = "RunningTaskCount"
      namespace   = "ECS/ContainerInsights"
      period      = 60
      stat        = "Average"

      dimensions = {
        ClusterName = var.ecs_cluster_name
        ServiceName = each.value
      }
    }
  }

  metric_query {
    id          = "desired"
    return_data = false

    metric {
      metric_name = "DesiredTaskCount"
      namespace   = "ECS/ContainerInsights"
      period      = 60
      stat        = "Average"

      dimensions = {
        ClusterName = var.ecs_cluster_name
        ServiceName = each.value
      }
    }
  }

  treat_missing_data = "missing"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = var.tags
}