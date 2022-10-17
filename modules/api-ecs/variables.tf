variable "region" {
  description = "AWS Region"
}

variable "application_name" {
  description = "Application name"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "random_id_prefix" {
  description = "random id prefix"
}

variable "ecr_api_repository_name" {
  description = "The name of the repisitory"
}

variable "aws_target_group_blue" {
  description = "ECS Target Group Blue"
}

variable "aws_target_group_green" {
  description = "ECS Target Group Green"
}

variable "ecs_execution_role" {
  description = "ECS Execute Role"
}

variable "security_groups_ids" {
  type        = list(any)
  description = "The SGs to use"
}

variable "ecs_security_group" {
  description = "ECS Security Group"
}

variable "private_subnets_ids" {
  type        = list(any)
  description = "Private subnets ids"
}


variable "container_port" {
  description = "ECS container port"
}

variable "scan_on_push" {
  description = "ECR scan on push"
}

variable "api_container_memory" {
  description = "API container memory"
}

variable "DATABASE_URL" {
  description = "DATABASE_URL for Prisma"
  type        = string
  sensitive   = true
}


variable "APOLLO_KEY" {
  description = "Apollo secret key of Apollo Studio for API container"
  type        = string
  sensitive   = true
}

variable "APOLLO_GRAPH_REF" {
  description = "Apollo Graph Ref value of Apollo Studio for API container"
  type        = string
  sensitive   = false
}

variable "S3_ACCESS_KEY_ID" {
  description = "AWS S3 Access Key ID"
  type        = string
  sensitive   = true
}
variable "S3_ACCESS_SECRET_ID" {
  description = "AWS S3 Access Secret ID"
  type        = string
  sensitive   = true
}
variable "IAMPORT_KEY" {
  description = "IAMPORT Access Key"
  type        = string
  sensitive   = true
}
variable "IAMPORT_SECRET_KEY" {
  description = "IAMPORT Access Secret Key"
  type        = string
  sensitive   = true
}
variable "API_SECRET" {
  description = "API Secret Key"
  type        = string
  sensitive   = true
}

variable "ssm_depends_on" {
  type    = any
  default = []
}
