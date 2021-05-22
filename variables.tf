variable "region" {
  description = "aws region to deploy to"
  type        = string
}

# variable "ecs_cloudwatchlog_group" {
#   description = "name of log group"
#   type = string
# }
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


#Commented because no need for Route53 at testing
# variable "zone_id" {
#   type = string
#   description = "Route53 Zone ID"  
# }
