locals {
  container_name = "${var.random_id_prefix}-${var.application_name}-${terraform.workspace}-api"
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = "rds-db-credentials/${var.application_name}/${terraform.workspace}/${var.random_id_prefix}"
  depends_on = [
    var.rds_depend_on
  ]
}

data "template_file" "codebuild-role" {
  template = file("${path.module}/policies/codebuild-role-policy.json")
  vars = {
    region      = "${var.region}"
    account_id  = "${data.aws_caller_identity.current.account_id}"
    subnet_id_1 = "${var.subnets_id_1}"
    subnet_id_2 = "${var.subnets_id_2}"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.random_id_prefix}-codebuild-role"
  assume_role_policy = file("${path.module}/policies/codebuild-role.json")
}

resource "aws_iam_role_policy" "codebuild_ec2container_policy" {
  name   = "${var.random_id_prefix}-codebuild-ec2container-policy"
  policy = file("${path.module}/policies/codepipeline-ec2container-role-policy.json")
  role   = aws_iam_role.codebuild_role.id
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.random_id_prefix}-codebuild-policy"
  # policy = file("${path.module}/policies/codebuild-role-policy.json")
  policy = data.template_file.codebuild-role.rendered
  role   = aws_iam_role.codebuild_role.id
}

resource "aws_iam_role_policy" "codebuild_ecs_policy" {
  name   = "${var.random_id_prefix}-ecs-policy"
  policy = file("${path.module}/policies/codebuild-ecs-role-policy.json")
  role   = aws_iam_role.codebuild_role.id
}



data "template_file" "buildspec" {
  template = file("${path.module}/buildspec/buildspec.yml")

  vars = {
    region                 = "${var.region}"
    ecr_api_repository_url = "${var.ecr_api_repository_url}"
    api_repository_name    = "${var.api_repository_name}"
    task_definition        = local.container_name
    apollo_graph_ref       = "${var.APOLLO_GRAPH_REF}"
    api_endpoint_url       = "${var.api_endpoint_url}"
    # task_definition        = "${var.application_name}-${terraform.workspace}-api"
  }
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = join("-", [var.random_id_prefix, var.buildproject_name, "codebuild"])
  description   = "API docker container image build"
  build_timeout = "50"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    # name                   = join("-", ["ecs-build", var.application_name, terraform.workspace])
    # override_artifact_name = true
    # packaging              = "NONE"
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.ecr_api_repository_url
    }

    environment_variable {
      name  = "TASK_DEFINITION"
      value = "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.ecs_api_task_defination_family}"
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = local.container_name
    }

    environment_variable {
      name  = "SUBNET_1"
      value = var.subnets_id_1
    }

    environment_variable {
      name  = "SUBNET_2"
      value = var.subnets_id_2
    }

    environment_variable {
      name  = "SECURITY_GROUP"
      value = var.ecs_security_group_id
    }

    environment_variable {
      name  = "DATABASE_URL"
      value = var.DATABASE_URL
    }

    environment_variable {
      name  = "APOLLO_KEY"
      value = var.APOLLO_KEY
    }

    environment_variable {
      name  = "APOLLO_GRAPH_REF"
      value = var.APOLLO_GRAPH_REF
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.template_file.buildspec.rendered

  }
  vpc_config {
    vpc_id = var.vpc_id

    subnets = [
      var.subnets_id_1,
      var.subnets_id_2
    ]

    security_group_ids = [
      var.ecs_security_group_id,
      var.rds_access_security_group_id,
      var.rds_db_security_group_id
    ]
  }
  depends_on = [
    var.ssm_depends_on
  ]
  tags = {
    Environment = "${terraform.workspace}"
  }
}
