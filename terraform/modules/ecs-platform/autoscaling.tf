# API autoscaling

resource "aws_appautoscaling_target" "api" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"

  min_capacity = var.api_min_capacity
  max_capacity = var.api_max_capacity
}

resource "aws_appautoscaling_policy" "api_cpu" {
  name               = "${var.name_prefix}-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  resource_id        = aws_appautoscaling_target.api.resource_id

  target_tracking_scaling_policy_configuration {
    target_value = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_out_cooldown = 60
    scale_in_cooldown  = 180
  }
}


# Worker autoscaling

resource "aws_appautoscaling_target" "worker" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.worker.name}"

  min_capacity = var.worker_min_capacity
  max_capacity = var.worker_max_capacity
}

resource "aws_appautoscaling_policy" "worker_backlog" {
  name               = "${var.name_prefix}-worker-backlog-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.worker.service_namespace
  scalable_dimension = aws_appautoscaling_target.worker.scalable_dimension
  resource_id        = aws_appautoscaling_target.worker.resource_id

  target_tracking_scaling_policy_configuration {
    target_value = var.worker_backlog_target

    customized_metric_specification {
      metrics {
        id          = "m1"
        label       = "Visible SQS messages"
        return_data = false

        metric_stat {
          metric {
            metric_name = "ApproximateNumberOfMessagesVisible"
            namespace   = "AWS/SQS"

            dimensions {
              name  = "QueueName"
              value = var.sqs_queue_name
            }
          }

          stat = "Sum"
        }
      }

      metrics {
        id          = "m2"
        label       = "Running Worker tasks"
        return_data = false

        metric_stat {
          metric {
            metric_name = "RunningTaskCount"
            namespace   = "ECS/ContainerInsights"

            dimensions {
              name  = "ClusterName"
              value = aws_ecs_cluster.main.name
            }

            dimensions {
              name  = "ServiceName"
              value = aws_ecs_service.worker.name
            }
          }

          stat = "Average"
        }
      }

      metrics {
        id          = "e1"
        label       = "Backlog per Worker"
        expression  = "m1 / m2"
        return_data = true
      }
    }

    scale_out_cooldown = 60
    scale_in_cooldown  = 180
  }
}


# Dashboard autoscaling

resource "aws_appautoscaling_target" "dashboard" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.dashboard.name}"

  min_capacity = var.dashboard_min_capacity
  max_capacity = var.dashboard_max_capacity
}

resource "aws_appautoscaling_policy" "dashboard_cpu" {
  name               = "${var.name_prefix}-dashboard-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.dashboard.service_namespace
  scalable_dimension = aws_appautoscaling_target.dashboard.scalable_dimension
  resource_id        = aws_appautoscaling_target.dashboard.resource_id

  target_tracking_scaling_policy_configuration {
    target_value = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_out_cooldown = 60
    scale_in_cooldown  = 180
  }
}