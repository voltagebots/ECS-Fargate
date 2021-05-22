resource "aws_ecs_service" "x" {
    provider = aws.current
    name = "ecs-${var.cluster_name}-${var.environment}-service"  
    cluster = var.cluster_id
    task_definition = aws_ecs_task_definition.x.family
    desired_count =  var.app_count
    launch_type = "FARGATE"
    health_check_grace_period_seconds = 120

    network_configuration {
        security_groups = [ var.aws_security_group_ecs_tasks_id ]
        subnets = var.private_subnet_ids      
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.alb_tg.arn
        container_name = var.cluster_name
        container_port = var.app_port
    }

    depends_on = [
      aws_ecs_task_definition.x
    ]
    lifecycle {
       ignore_changes = [desired_count, task_definition]
    }    
}

resource "aws_appautoscaling_target" "cx" {
  provider = aws.current
  max_capacity       = var.max_autoscaling
  min_capacity       = var.min_autoscaling
  resource_id        = "service/${var.cluster_name}-${var.environment}-cluster/${aws_ecs_service.x.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.admin_tool]
}

resource "aws_appautoscaling_policy" "memory_util" {
  provider = aws.current
  name               = "${var.cluster_name}-${var.environment}-mem-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.x.resource_id
  scalable_dimension = aws_appautoscaling_target.x.scalable_dimension
  service_namespace  = aws_appautoscaling_target.x.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 80

    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.x]
}

resource "aws_appautoscaling_policy" "cpu_util" {
  provider = aws.current
  name               = "${var.cluster_name}-${var.environment}-cpu-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.x.resource_id
  scalable_dimension = aws_appautoscaling_target.x.scalable_dimension
  service_namespace  = aws_appautoscaling_target.x.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60

    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.x]
}
