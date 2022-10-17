variable "region" {
  description = "AWS Region"
}

variable "application_name" {
  description = "Application name"
}

variable "random_id_prefix" {
  description = "random id prefix"
}

variable "ecs_autoscale_role" {
  description = "ECS AutoScale Role"
}

variable "ecs_cluster_name" {
  description = "ECS Cluster Name"
}

variable "ecs_service_name" {
  description = "ECS Service Name"
}
