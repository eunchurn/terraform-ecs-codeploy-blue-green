variable "region" {
  description = "AWS Region"
}

variable "random_id_prefix" {
  description = "random prefix"
}

variable "ecs_cluster_name" {
  description = "ecs cluster name"
}

variable "api_service_name" {
  description = "api_service_name"
}

variable "aws_target_group_blue_name" {
  description = "API AWS Target Group Blue name"
}

variable "aws_target_group_green_name" {
  description = "API AWS Target Group Green name"
}

variable "api_alb_listener_arn" {
  description = "API AWS Load Balancer Listener arn"
}

variable "api_alb_test_listener_arn" {
  description = "API AWS Load Balancer Test Listener arn"
}

variable "ecs_execution_role_arn" {
  description = "ecs_execution_role_arn"
}
