locals {
  container_name = "${var.random_id_prefix}-${var.application_name}-${terraform.workspace}-api"
}

data "aws_ecs_task_definition" "api" {
  task_definition = aws_ecs_task_definition.api.family
  depends_on      = [aws_ecs_task_definition.api]
}

module "parameters" {
  source = "./parameters"

  application_name = var.application_name
  ssm_depends_on   = var.ssm_depends_on
}

resource "aws_ecr_repository" "api" {
  name = var.ecr_api_repository_name

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  force_delete = true

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_ecr_lifecycle_policy" "api_policy" {
  repository = aws_ecr_repository.api.name

  policy = file("${path.module}/policies/ecs-lifecycle-policy.json")
}

# ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.application_name}-api-${terraform.workspace}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = "${terraform.workspace}"
  }
}

# AWS Service discovery service

resource "aws_service_discovery_private_dns_namespace" "private_dns_name" {
  name        = "${var.application_name}.local"
  description = "Private DNS"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "private_dns" {
  name = terraform.workspace

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_name.id

    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  force_destroy = true
}

# ECS Service
resource "aws_ecs_service" "api" {
  name                   = local.container_name
  task_definition        = "${aws_ecs_task_definition.api.family}:${max("${aws_ecs_task_definition.api.revision}", "${data.aws_ecs_task_definition.api.revision}")}"
  desired_count          = 1
  launch_type            = "FARGATE"
  cluster                = aws_ecs_cluster.cluster.id
  enable_execute_command = true

  network_configuration {
    security_groups  = flatten(["${var.security_groups_ids}", "${var.ecs_security_group.id}"])
    subnets          = flatten(["${var.private_subnets_ids}"])
    assign_public_ip = true
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  propagate_tags          = "TASK_DEFINITION"
  enable_ecs_managed_tags = true

  health_check_grace_period_seconds = 30


  load_balancer {
    target_group_arn = var.aws_target_group_blue.arn
    container_name   = local.container_name
    container_port   = "8000"
  }

  # load_balancer {
  #   target_group_arn = var.aws_target_group_green.arn
  #   container_name   = local.container_name
  #   container_port   = "8000"
  # }
  service_registries {
    registry_arn = aws_service_discovery_service.private_dns.arn
  }

  tags = {
    Environment = "${terraform.workspace}"
  }
  depends_on = [var.ssm_depends_on]
  lifecycle {
    ignore_changes = [
      desired_count,
      load_balancer,
      network_configuration,
      task_definition
    ]
  }
}

resource "aws_cloudwatch_log_group" "api_log" {
  name              = "${var.random_id_prefix}-${var.application_name}-${terraform.workspace}"
  retention_in_days = 30

  tags = {
    Environment = "${terraform.workspace}"
    Application = "${var.application_name}-api"
  }
}

resource "aws_cloudwatch_log_stream" "api_log_stream" {
  name           = "${var.random_id_prefix}-${terraform.workspace}-jobs-log-stream"
  log_group_name = aws_cloudwatch_log_group.api_log.name
}

## ECS task definitions

resource "aws_ecs_task_definition" "api" {
  family                   = local.container_name
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${local.container_name}",
      "image": "${aws_ecr_repository.api.repository_url}",
      "portMappings": [
        {
          "containerPort": 8000,
          "hostPort": 8000
        }
      ],
      "memory": ${var.api_container_memory},
      "networkMode": "awsvpc",
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "${module.parameters.DATABASE_URL.name}"
        },
        {
          "name": "APOLLO_KEY",
          "valueFrom": "${module.parameters.APOLLO_KEY.name}"
        },
        {
          "name": "S3_ACCESS_KEY_ID",
          "valueFrom": "${module.parameters.S3_ACCESS_KEY_ID.name}"
        },
        {
          "name": "S3_ACCESS_SECRET_ID",
          "valueFrom": "${module.parameters.S3_ACCESS_SECRET_ID.name}"
        },
        {
          "name": "IAMPORT_KEY",
          "valueFrom": "${module.parameters.IAMPORT_KEY.name}"
        },
        {
          "name": "IAMPORT_SECRET_KEY",
          "valueFrom": "${module.parameters.IAMPORT_SECRET_KEY.name}"
        },
        {
          "name": "API_SECRET",
          "valueFrom": "${module.parameters.API_SECRET.name}"
        }
      ],
      "environment": [
        {
          "name": "API_ENV",
          "value": "${terraform.workspace}"
        },
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.api_log.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "linuxParameters": {
        "initProcessEnabled": true
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role.arn
  task_role_arn            = var.ecs_execution_role.arn
  depends_on = [
    var.ssm_depends_on
  ]
  tags = {
    Environment = "${terraform.workspace}"
  }
}

