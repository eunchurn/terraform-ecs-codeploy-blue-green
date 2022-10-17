output "api_repository_url" {
  value = aws_ecr_repository.api.repository_url
}

output "api_repository_name" {
  value = aws_ecr_repository.api.name
}

output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "api_service_name" {
  value = aws_ecs_service.api.name
}

output "ecs_api_task_defination_family" {
  value = aws_ecs_task_definition.api.family
}

output "api_ecs_cluster_id" {
  value = aws_ecs_cluster.cluster
}

output "api_ecs_task_id" {
  value = data.aws_ecs_task_definition.api
}

output "api_ecs_service" {
  value = aws_ecs_service.api
}
