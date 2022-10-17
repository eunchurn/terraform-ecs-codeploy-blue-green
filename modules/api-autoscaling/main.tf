## Auto Scaling for ECS

resource "aws_appautoscaling_target" "target_api" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = var.ecs_autoscale_role.arn
  min_capacity       = 1
  max_capacity       = 4
}

resource "aws_appautoscaling_policy" "up_api" {
  name               = "${var.random_id_prefix}-${terraform.workspace}_scale_up_api"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target_api]
}

resource "aws_appautoscaling_policy" "down_api" {
  name               = "${var.random_id_prefix}-${terraform.workspace}_scale_down_api"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target_api]
}

resource "aws_appautoscaling_policy" "cpu_tracking" {
  name               = "${var.random_id_prefix}-${terraform.workspace}_cpu_tracking"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 99
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }

  depends_on = [aws_appautoscaling_target.target_api]
}

## metric used for auto scale

resource "aws_cloudwatch_metric_alarm" "service_cpu_high_api" {
  alarm_name          = "${var.random_id_prefix}-${var.application_name}-${terraform.workspace}_application_cpu_utilization_high_api"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "85"

  dimensions = {
    ClusterName = "${var.ecs_cluster_name}"
    ServiceName = "${var.ecs_service_name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.up_api.arn}"]
  ok_actions    = ["${aws_appautoscaling_policy.down_api.arn}"]
}
