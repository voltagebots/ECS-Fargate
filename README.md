Terraform Module for Elastic Container Service - Fargate.
Resources declared are:

1.VPC:
    * VPC Endpoints
    * Natgateway
    * Subnets
    * Internet Gateway
    * Public and Private Router
    * Security Group
2.ECS Cluster
3.ECS Fargate:
    * ALB
    * ECS Task Definition
    * ECS Service
For efficient implementaton, you need a minimum of three files in your application folder: main.tf provider.tf variables.tf

HOW TO USE IT

Ensure you set up necessary backends and Makefile befor implementing.

Example maim.yaml
module "vpc_for_ecs_fargate" {
  providers = {
    aws.current = aws.beta-east-1
  }
  source = "./vpc"
  vpc_tag_name = "${var.cluster_name}-vpc"
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

#ECS cluster
module "ecs_cluster" {
  providers = {
    aws.current = aws.beta-east-1
  }
  source = "./ecs_cluster"
  cluster_name = "${var.cluster_name}-${var.environment}-cluster"
  cluster_tag_name = "${var.cluster_name}-${var.environment}-cluster"
  environment = "dev"
}

#ECS task definition and service
module "ecs_task_definition_and_service" {
  #Task definition and NLB
  providers = {
    aws.current = aws.beta-east-1
  }
  source = "./ecs_fargate"
  cluster_name = "${var.cluster_name}-${var.environment}"
  app_image = var.app_image
  fargate_cpu                 = 1024
  fargate_memory              = 2048
  app_port = var.app_port
  vpc_id = module.vpc_for_ecs_fargate.vpc_id
  environment = var.environment
  enable_lb_deletion = false
  internal_loadbalancer = false
  alb_sg_group = module.vpc_for_ecs_fargate.alb_security_group_id
  #Service
  cluster_id = module.ecs_cluster.cluster_id
  app_count = var.app_count
  aws_security_group_ecs_tasks_id = module.vpc_for_ecs_fargate.ecs_tasks_security_group_id
  public_subnet_ids = module.vpc_for_ecs_fargate.public_subnet_ids
  private_subnet_ids = module.vpc_for_ecs_fargate.private_subnet_ids
}
NOTE a = aws_access_key, s = aws_secret_access_key
Example provider.yaml
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.27.0"
    }
  }
}

################################################################################
#AWS STS Credentials Beta

locals {
  aws_regions = {
    "r0"  = "us-east-1"      # 20060825 - N Virginia, USA
    "r1"  = "eu-west-1"      # 20081210 - Dublin, Ireland
    "r2"  = "us-west-1"      # 20091203 - N California, USA
  }
}

locals {
  gsuite_beta = {
    a = ""
    s = ""
  }
}

#AWS Providers Beta
provider "aws" {
  alias      = "beta-east-1"
  access_key = local.gsuite_beta["a"]
  secret_key = local.gsuite_beta["s"]
  region     = local.aws_regions["r0"]
}

provider "aws" {
  alias      = "beta-west-1"
  access_key = local.gsuite_beta["a"]
  secret_key = local.gsuite_beta["s"]
  region     = local.aws_regions["r1"]
}
Example variables.tf
variable "profile" {
  description = "AWS profile"
  type        = string
}

variable "region" {
  description = "aws region to deploy to"
  type        = string
}

variable "cluster_name" {
  description = "The name of the platform"
  type = string
}

variable "environment" {
  description = "Applicaiton environment"
  type = string
}

variable "app_port" {
  description = "Application port"
  type = number
}

variable "app_image" {
  type = string 
  description = "Container image to be used for application in task definition file"
}

variable "availability_zones" {
  type  = list(string)
  description = "List of availability zones for the selected region"
}

variable "app_count" {
  type = string 
  description = "The number of instances of the task definition to place and keep running."
}

variable "main_pvt_route_table_id" {
  type        = string
  description = "Main route table id"
}
variable "domain_name" {
  type = string
  description = "The DNS domain name of the application"
}

variable "load_balancer_arn" {
  type = string
  description = "The ARN of Application Load Balancer"
}

variable "target_group_arn" {
  type = string
  description = "AL Target group arn"  
}

variable "zone_id" {
  type = string
  description = "Route53 Zone ID"  
}

variable "record_ttl" {
  type = number
  default = 120  
}
DNS, ACM and SSL
module "admin_tool_dns" {
  providers = {
    aws.current = aws.beta-east-1
   }
  source = "./dns"
  domain_name = ""
  load_balancer_arn = module.ecs_task_definition_and_service.alb_arn
  target_group_arn = module.ecs_task_definition_and_service.target_group_arn
  zone_id = var.zone_id
}
#TODO: Secret Manager, Terraform Pipeline
