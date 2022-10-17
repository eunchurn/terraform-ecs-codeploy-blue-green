variable "region" {
  description = "AWS region..."
}

variable "application_name" {
  description = "Application name"
}

variable "random_id_prefix" {
  description = "random prefix"
}

variable "buildproject_name" {
  description = "build project name..."
}

variable "ecr_api_repository_url" {
  description = "ecr be repository url..."
}

variable "api_repository_name" {
  description = "ecr be repository name..."
}


variable "api_container_memory" {
  description = "api_container_memory"
}

variable "api_endpoint_url" {
  description = "API Endpoint URL"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "subnets_id_1" {
  description = "subnets ids"
}

variable "subnets_id_2" {
  description = "subnets ids"
}

variable "public_subnet_id_1" {
  description = "public subnets ids"
}

variable "public_subnet_id_2" {
  description = "public subnets ids"
}

variable "security_groups_ids" {
  type        = list(any)
  description = "The SGs to use"
}

variable "ecs_security_group_id" {
  description = "ecs_security_group_id"
}

variable "rds_access_security_group_id" {
  description = "RDS Access Security Group ID"
}

variable "rds_db_security_group_id" {
  description = "RDS DB Securuty Group ID"
}

variable "ecs_api_task_defination_family" {
  description = "ecs_api_task_defination_family"
}

variable "DATABASE_URL" {
  description = "DATABASE_URL for Prisma"
}

variable "APOLLO_KEY" {
  description = "APOLLO_KEY of Apollo Studio for API"
}

variable "APOLLO_GRAPH_REF" {
  description = "APOLLO_GRAPH_REF of Apollo Studio for API"
}

variable "ssm_depends_on" {
  type    = any
  default = []
}

variable "rds_depend_on" {
  description = "RDS depend on"
  type        = any
  default     = []
}
