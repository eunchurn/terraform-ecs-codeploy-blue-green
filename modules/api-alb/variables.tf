variable "region" {
  description = "AWS Region"
}

variable "application_name" {
  description = "Application name"
}

variable "random_id_prefix" {
  description = "random id prefix"
}

variable "vpc_id" {
  description = "vpc id"
}


variable "public_subnet_ids" {
  type        = list(any)
  description = "Public subnets to use"
}

variable "security_groups_ids" {
  type        = list(any)
  description = "The SGs to use"
}

variable "ecs_security_group" {
  description = "ECS Security group"
}

variable "alb_security_group" {
  description = "ALB Security group"
}


variable "root_domain" {
  description = "Root domain"
  type        = string
  default     = "platform.mystack.io"

}
