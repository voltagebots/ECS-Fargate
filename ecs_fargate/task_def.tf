resource "aws_ecs_task_definition" "x" {
    provider = aws.current
    family = var.cluster_name
    task_role_arn = aws_iam_role.ecs_task_role.arn
    execution_role_arn = aws_iam_role.ecs_main_tasks.arn
    network_mode = "awsvpc"
    requires_compatibilities = [ "FARGATE" ]
    cpu = var.fargate_cpu
    memory = var.fargate_memory
    container_definitions = jsonencode([
        {
            name : var.cluster_name
            image : var.app_image
            cpu : var.fargate_cpu,
            memory : var.fargate_memory,
            networkMode : "awsvpc",
            logConfiguration : {
                logDriver: "awslogs",
                options: {
                    "awslogs-group": "/ecs/x",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                    }
                },
            environment : [
                {
                    "name": "DB_NAME",
                    "value": "x"
                },
                {
                    "name": "ENVIRONMENT",
                    "value": "x"
                },
                {
                    "name": "SECRET_MANAGER_NAME",
                    "value": "x"
                }
            ],
            portMappings : [
                {
                    containerPort : var.app_port
                    protocol : "tcp",
                    hostPort : var.app_port
                }
            ]
        }
    ])
}
