module "vpc_for_ecs_fargate" {
  providers = {
    aws.current = aws.beta-east-1
  }
  source = "./vpc"
  vpc_tag_name = var.cluster_name
  number_of_private_subnets = 2
  number_of_public_subnets = 2
  private_subnet_tag_name = "${var.cluster_name}-private-subnet"
  public_subnet_tag_name = "${var.cluster_name}-public-subnet"
  environment = var.environment
  security_group_lb_name = "${var.cluster_name}-alb-sg"
  security_group_ecs_tasks_name = "${var.cluster_name}-ecs-tasks-sg"
  app_port = var.app_port
  availability_zones = var.availability_zones
  region = var.region
}

# ECS cluster
module "ecs_cluster" {
  providers = {
    aws.current = aws.beta-east-1
  }
  source = "./ecs_cluster"
  cluster_name = var.cluster_name
  cluster_tag_name = "${var.cluster_name}-${var.environment}-cluster"
  environment = "dev"
}

# ECS task definition and service
module "ecs_task_definition_and_service" {
  # Task definition and NLB
  providers = {
    aws.current = aws.beta-east-1
  }
  source = "./ecs_fargate"
  cluster_name = var.cluster_name
  app_image = var.app_image
  fargate_cpu                 = 1024
  fargate_memory              = 2048
  app_port = var.app_port
  vpc_id = module.vpc_for_ecs_fargate.vpc_id
  environment = var.environment
  database_name  = "x"
  app_environment = "sx"
  secrets_name  = "x"
  enable_lb_deletion = false
  internal_loadbalancer = false
  alb_sg_group = module.vpc_for_ecs_fargate.alb_security_group_id
  #Health Check
  interval = 60
  path = "/"
  healthy_threshold = 5
  unhealthy_threshold = 3
  timeout = 30
  matcher = 302
  #HTTPS
  create_https_listener = false #Set to true if you have certicicate provisioned.
  acm_certificate_arn = ""
  # Service
  cluster_id = module.ecs_cluster.cluster_id
  app_count = var.app_count
  aws_security_group_ecs_tasks_id = module.vpc_for_ecs_fargate.ecs_tasks_security_group_id
  public_subnet_ids = module.vpc_for_ecs_fargate.public_subnet_ids
  private_subnet_ids = module.vpc_for_ecs_fargate.private_subnet_ids
  #S3
  region         =   "us-east-1"
  bucket_name    =   "tx"
}


# module "admin_tool_dns" {
#   providers = {
#     aws.current = aws.beta-east-1
#    }
#   source = "./dns"
#   environment = var.environment
#   domain_name = ""
#   load_balancer_arn = module.ecs_task_definition_and_service.alb_arn
#   target_group_arn = module.ecs_task_definition_and_service.target_group_arn
#   zone_id = var.zone_id
# }

# API Gateway and VPC link
# module "api_gateway" {
  # providers = {
  #   aws.current = aws.beta-east-1
  # }
#   source = "./api_gateway"
#   cluster_name = "${var.cluster_name}-${var.environment}"
#   input_integration_type = "HTTP_PROXY"
#   path_part = "{proxy+}"
#   app_port = var.app_port
#   nlb_dns_address = module.ecs_task_definition_and_service.nlb_dns_address
#   nlb_arn = module.ecs_task_definition_and_service.nlb_arn
#   environment = var.environment
# }
