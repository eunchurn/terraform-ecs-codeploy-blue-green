provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

resource "random_id" "random_id_prefix" {
  byte_length = 2
}

# Terraform state management
# https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa
terraform {
  backend "s3" {
    bucket = "mystack-terraform-running-state"
    key    = "global/s3/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "mystack-terraform-running-locks"
    encrypt        = true
  }
}

// Only use very first `default` workspace state creation
# data "terraform_remote_state" "network" {
#   backend = "s3"
#   config = {
#     bucket = "mystack-terraform-running-state"
#     key    = "global/s3/terraform.tfstate"
#     region = "ap-northeast-2"
#   }
# }

# module "terraform_state" {
#   source                               = "./modules/terraform-state"
#   s3_terraform_state_bucket_name       = "mystack-terraform-running-state"
#   s3_terraform_state_key               = "global/s3/terraform.tfstate"
#   dynamodb_terraform_state_locks_table = "mystack-terraform-running-locks"
# }

# AWS SSM Paremeter

module "ssm-parameter" {
  source = "./modules/ssm"

  application_name    = var.application_name
  random_id_prefix    = random_id.random_id_prefix.hex
  rds_depend_on       = module.database
  APOLLO_KEY          = var.APOLLO_KEY
  APOLLO_GRAPH_REF    = "${var.APOLLO_GRAPH_REF}${terraform.workspace}"
  S3_ACCESS_KEY_ID    = var.S3_ACCESS_KEY_ID
  S3_ACCESS_SECRET_ID = var.S3_ACCESS_SECRET_ID
  IAMPORT_KEY         = var.IAMPORT_KEY
  IAMPORT_SECRET_KEY  = var.IAMPORT_SECRET_KEY
  API_SECRET          = var.API_SECRET
}

module "networks" {
  source               = "./modules/networks"
  application_name     = var.application_name
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = data.aws_availability_zones.available.names
  namespace_name       = "${var.application_name}.${terraform.workspace}"
}

module "storage" {
  source                = "./modules/storage"
  application_name      = var.application_name
  uploads_bucket_prefix = "${random_id.random_id_prefix.hex}-assets"
}

module "codebuild" {
  source = "./modules/codebuild"

  region                         = var.region
  application_name               = var.application_name
  random_id_prefix               = random_id.random_id_prefix.hex
  buildproject_name              = var.buildproject_name
  ecr_api_repository_url         = module.api-ecs.api_repository_url
  api_repository_name            = module.api-ecs.api_repository_name
  api_container_memory           = var.api_container_memory
  vpc_id                         = module.networks.vpc_id
  security_groups_ids            = module.networks.security_groups_ids
  ecs_security_group_id          = module.api-sg.ecs_security_group.id
  rds_access_security_group_id   = module.database.aws_rds_access_security_group_ids
  rds_db_security_group_id       = module.database.aws_rds_db_security_group_ids
  subnets_id_1                   = module.networks.private_subnet_1
  public_subnet_id_1             = module.networks.public_subnet_1
  subnets_id_2                   = module.networks.private_subnet_2
  public_subnet_id_2             = module.networks.public_subnet_2
  ecs_api_task_defination_family = module.api-ecs.ecs_api_task_defination_family
  DATABASE_URL                   = module.ssm-parameter.DATABASE_URL
  APOLLO_KEY                     = module.ssm-parameter.APOLLO_KEY
  APOLLO_GRAPH_REF               = module.ssm-parameter.APOLLO_GRAPH_REF
  api_endpoint_url               = "https://${module.api-alb.route53.fqdn}"
  ssm_depends_on                 = module.ssm-parameter
  rds_depend_on                  = module.database
}

module "codedeploy" {
  source = "./modules/codedeploy"

  region                      = var.region
  random_id_prefix            = random_id.random_id_prefix.hex
  ecs_execution_role_arn      = module.api-iam.ecs_execution_role.arn
  ecs_cluster_name            = module.api-ecs.cluster_name
  api_service_name            = module.api-ecs.api_service_name
  aws_target_group_blue_name  = module.api-alb.aws_target_group_blue.name
  aws_target_group_green_name = module.api-alb.aws_target_group_green.name
  api_alb_listener_arn        = module.api-alb.aws_alb_blue_green.arn
  api_alb_test_listener_arn   = module.api-alb.aws_alb_test_blue_green.arn
}

module "codepipeline" {
  source = "./modules/codepipeline"

  region              = var.region
  random_id_prefix    = random_id.random_id_prefix.hex
  api_pipeline_name   = var.api_pipeline_name
  buildproject_name   = module.codebuild.build_project_name
  api_repository_name = var.api_repository_name
  cluster_name        = module.api-ecs.cluster_name
  api_service_name    = module.api-ecs.api_service_name
}

module "api-iam" {
  source = "./modules/api-iam"

  application_name = var.application_name
  region           = var.region
  random_id_prefix = random_id.random_id_prefix.hex
}

module "api-alb" {
  source = "./modules/api-alb"

  application_name    = var.application_name
  region              = var.region
  random_id_prefix    = random_id.random_id_prefix.hex
  vpc_id              = module.networks.vpc_id
  public_subnet_ids   = ["${module.networks.public_subnets_id}"]
  security_groups_ids = module.networks.security_groups_ids
  ecs_security_group  = module.api-sg.ecs_security_group
  alb_security_group  = module.api-sg.alb_security_group
  root_domain         = var.root_domain
}

module "api-ecs" {
  source = "./modules/api-ecs"

  application_name        = var.application_name
  region                  = var.region
  vpc_id                  = module.networks.vpc_id
  random_id_prefix        = random_id.random_id_prefix.hex
  ecr_api_repository_name = "${var.ecr_api_repository_name}-${terraform.workspace}-${random_id.random_id_prefix.hex}"
  aws_target_group_blue   = module.api-alb.aws_target_group_blue
  aws_target_group_green  = module.api-alb.aws_target_group_green
  ecs_execution_role      = module.api-iam.ecs_execution_role
  security_groups_ids     = module.networks.security_groups_ids
  ecs_security_group      = module.api-sg.ecs_security_group
  private_subnets_ids     = ["${module.networks.private_subnets_id}"]
  container_port          = var.api_container_port
  scan_on_push            = var.scan_on_push
  api_container_memory    = var.api_container_memory
  DATABASE_URL            = module.ssm-parameter.DATABASE_URL
  APOLLO_KEY              = module.ssm-parameter.APOLLO_KEY
  APOLLO_GRAPH_REF        = module.ssm-parameter.APOLLO_GRAPH_REF
  S3_ACCESS_KEY_ID        = module.ssm-parameter.S3_ACCESS_KEY_ID
  S3_ACCESS_SECRET_ID     = module.ssm-parameter.S3_ACCESS_SECRET_ID
  IAMPORT_KEY             = module.ssm-parameter.IAMPORT_KEY
  IAMPORT_SECRET_KEY      = module.ssm-parameter.IAMPORT_SECRET_KEY
  API_SECRET              = module.ssm-parameter.API_SECRET
  ssm_depends_on          = module.ssm-parameter
}

module "api-autoscaling" {
  source = "./modules/api-autoscaling"

  application_name   = var.application_name
  region             = var.region
  random_id_prefix   = random_id.random_id_prefix.hex
  ecs_autoscale_role = module.api-iam.ecs_execution_role
  ecs_cluster_name   = module.api-ecs.cluster_name
  ecs_service_name   = module.api-ecs.api_service_name
}

module "api-sg" {
  source = "./modules/api-sg"

  application_name = var.application_name
  region           = var.region
  random_id_prefix = random_id.random_id_prefix.hex
  vpc_id           = module.networks.vpc_id
  container_port   = var.api_container_port
}
module "database" {
  source = "./modules/database"

  application_name                    = var.application_name
  random_id_prefix                    = random_id.random_id_prefix.hex
  global_cluster_identifier           = "${var.application_name}-${terraform.workspace}-${random_id.random_id_prefix.hex}"
  cluster_identifier                  = "${var.application_name}-${terraform.workspace}-${random_id.random_id_prefix.hex}"
  replication_source_identifier       = var.replication_source_identifier
  source_region                       = var.region
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  database_name                       = var.database_name
  master_username                     = var.master_username
  vpc_security_group_ids              = module.networks.default_sg_id
  db_cluster_parameter_group_name     = var.db_cluster_parameter_group_name
  subnet_ids                          = ["${module.networks.private_subnets_id}"]
  final_snapshot_identifier           = "${terraform.workspace}-snapshot-${random_id.random_id_prefix.dec}"
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  skip_final_snapshot                 = var.skip_final_snapshot
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backtrack_window                    = var.backtrack_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  deletion_protection                 = var.deletion_protection
  auto_pause                          = var.auto_pause
  max_capacity                        = var.max_capacity
  min_capacity                        = var.min_capacity
  seconds_until_auto_pause            = var.seconds_until_auto_pause
  api_server_sg                       = module.api-sg.ecs_security_group.id
  vpc_id                              = module.networks.vpc_id
}
