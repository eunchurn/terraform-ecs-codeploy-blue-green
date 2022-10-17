terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.22.0"
    }
  }
}
resource "docker_image" "supertokens" {
  name = "registry.supertokens.io/supertokens/supertokens-postgresql"
}

resource "docker_container" "supertokens" {
  image = docker_image.supertokens.image_id
  name  = "supertokens-container"
}

resource "aws_ecr_repository" "supertokens" {
  name = var.ecr_auth_repository_name
}

resource "aws_ecs_cluster" "supertokens" {
  name = "${var.application_name}-auth-${terraform.workspace}"
}

resource "aws_ecs_task_definition" "supertokens" {
  family                   = "${var.application_name}-auth-${terraform.workspace}"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.application_name}-auth-${terraform.workspace}",
      "image": "${aws_ecr_repository.supertokens.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3567,
          "hostPort": 3567
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  # execution_role_arn       = aws_iam_role.ecs
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "${var.random_id_prefix}-auth-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
