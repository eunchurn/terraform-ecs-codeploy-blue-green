variable "application_name" {
  description = "Application name"
  type        = string
  default     = "mystack"
}

variable "region" {
  description = "The region Terraform deploys these stacks"
  type        = string
  default     = "ap-northeast-2"
}

## Networks: VPC, Subnet, NAT, Route
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    # "10.0.3.0/24",
    # "10.0.4.0/24",
    # "10.0.5.0/24",
    # "10.0.6.0/24",
    # "10.0.7.0/24",
    # "10.0.8.0/24",
  ]
}

variable "private_subnets_cidr" {
  description = "Available cidr blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    # "10.0.103.0/24",
    # "10.0.104.0/24",
    # "10.0.105.0/24",
    # "10.0.106.0/24",
    # "10.0.107.0/24",
    # "10.0.108.0/24",
  ]
}

## API ECS: Fargate

variable "ecr_api_repository_name" {
  description = "The name of API repository"
  type        = string
  default     = "mystack-api"
}

variable "ecr_auth_repository_name" {
  description = "The name of Auth repository"
  type        = string
  default     = "mystack-auth"
}

variable "aws_cloudwatch_log_group" {
  description = "aws_cloudwatch_log_group"
  type        = string
  default     = "ecs/mystack/log"
}

variable "scan_on_push" {
  description = "ECR scan on push"
  type        = bool
  default     = true
}

variable "api_container_memory" {
  description = "API container memory"
  type        = number
  default     = 512
}

variable "api_container_port" {
  description = "API container port"
  type        = number
  default     = 8000
}

variable "root_domain" {
  description = "Root domain of this application (API)"
  type        = string
  default     = "platform.mystack.io"
}

## RDS

variable "replication_source_identifier" {
  description = "replication source identifier"
  type        = string
  default     = "source_identifier"
}

variable "engine" {
  description = "engine"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_mode" {
  description = "engine mode"
  type        = string
  default     = "serverless"
}

variable "database_name" {
  description = "database name"
  type        = string
  default     = "authdb"
}

variable "master_username" {
  description = "master username"
  type        = string
  default     = "postgres"
}

variable "db_cluster_parameter_group_name" {
  description = "db cluster parameter group name"
  type        = string
  default     = "cluster_parameter"
}

variable "final_snapshot_identifier" {
  description = "final snapshot identifier"
  type        = string
  default     = "finalsnapshot"
}

variable "backup_retention_period" {
  description = "backup retention period"
  type        = number
  default     = 14
}

variable "preferred_backup_window" {
  description = "preferred backup window"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "preferred maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "skip_final_snapshot" {
  description = "skip final snapshot"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "storage encrypted"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "apply immediately"
  type        = bool
  default     = true
}

variable "iam_database_authentication_enabled" {
  description = "iam database authentication enabled"
  type        = bool
  default     = false
}

variable "backtrack_window" {
  description = "backtrack window"
  type        = number
  default     = 0
}

variable "copy_tags_to_snapshot" {
  description = "copy tags to snapshot"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "deletion protection"
  type        = bool
  default     = true
}

variable "auto_pause" {
  description = "auto pause"
  type        = bool
  default     = true
}

variable "max_capacity" {
  description = "max capacity"
  type        = number
  default     = 4
}

variable "min_capacity" {
  description = "min capacity"
  type        = number
  default     = 2
}

variable "seconds_until_auto_pause" {
  description = "seconds until auto pause"
  type        = number
  default     = 300
}

## CodeBuild
variable "buildproject_name" {
  description = "Build project name"
  type        = string
  default     = "mystack-api"
}

## API: CodePipeline
variable "api_pipeline_name" {
  description = "Code pipeline project name"
  type        = string
  default     = "mystack-api-pipeline"
}

variable "api_repository_name" {
  description = "API Repository Name"
  type        = string
  default     = "mystack-api"
}


# AWS SSM Parameter store

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
