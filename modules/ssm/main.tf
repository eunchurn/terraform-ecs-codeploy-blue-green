## DB Secrets

data "aws_secretsmanager_secret" "by-name" {
  name = "rds-db-credentials/${var.application_name}/${terraform.workspace}/${var.random_id_prefix}"
  depends_on = [
    var.rds_depend_on
  ]
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = data.aws_secretsmanager_secret.by-name.id
}

## Setting SSM Environment value

resource "aws_ssm_parameter" "DATABASE_URL" {
  name        = "/${var.application_name}/${terraform.workspace}/DATABASE_URL"
  description = "DATABASE_URL"
  type        = "SecureString"
  value       = "postgresql://${jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["username"]}:${jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["password"]}@${jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["host"]}:${jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["port"]}/apidb?schema=public"
  overwrite   = true
}

resource "aws_ssm_parameter" "APOLLO_KEY" {
  name        = "/${var.application_name}/${terraform.workspace}/APOLLO_KEY"
  description = "APOLLO_KEY of Apollo Studio for API Container"
  type        = "SecureString"
  value       = var.APOLLO_KEY
}

resource "aws_ssm_parameter" "APOLLO_GRAPH_REF" {
  name        = "/${var.application_name}/${terraform.workspace}/APOLLO_GRAPH_REF"
  description = "Apollo Graph Ref value of Apollo Studio for API container"
  type        = "SecureString"
  value       = var.APOLLO_GRAPH_REF
}

resource "aws_ssm_parameter" "S3_ACCESS_KEY_ID" {
  name        = "/${var.application_name}/${terraform.workspace}/S3_ACCESS_KEY_ID"
  description = "AWS S3 Access Key ID"
  type        = "SecureString"
  value       = var.S3_ACCESS_KEY_ID
}

resource "aws_ssm_parameter" "S3_ACCESS_SECRET_ID" {
  name        = "/${var.application_name}/${terraform.workspace}/S3_ACCESS_SECRET_ID"
  description = "AWS S3 Access Secret ID"
  type        = "SecureString"
  value       = var.S3_ACCESS_SECRET_ID
}

resource "aws_ssm_parameter" "IAMPORT_KEY" {
  name        = "/${var.application_name}/${terraform.workspace}/IAMPORT_KEY"
  description = "IAMPORT Access Key"
  type        = "SecureString"
  value       = var.IAMPORT_KEY
}

resource "aws_ssm_parameter" "IAMPORT_SECRET_KEY" {
  name        = "/${var.application_name}/${terraform.workspace}/IAMPORT_SECRET_KEY"
  description = "IAMPORT Access Secret Key"
  type        = "SecureString"
  value       = var.IAMPORT_SECRET_KEY
}

resource "aws_ssm_parameter" "API_SECRET" {
  name        = "/${var.application_name}/${terraform.workspace}/API_SECRET"
  description = "API Secret Key"
  type        = "SecureString"
  value       = var.API_SECRET
}
