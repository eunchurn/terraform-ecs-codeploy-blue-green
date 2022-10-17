
data "aws_ssm_parameter" "DATABASE_URL" {
  name       = "/${var.application_name}/${terraform.workspace}/DATABASE_URL"
  depends_on = [var.ssm_depends_on]
}
data "aws_ssm_parameter" "APOLLO_KEY" {
  name       = "/${var.application_name}/${terraform.workspace}/APOLLO_KEY"
  depends_on = [var.ssm_depends_on]
}
data "aws_ssm_parameter" "APOLLO_GRAPH_REF" {
  name       = "/${var.application_name}/${terraform.workspace}/APOLLO_GRAPH_REF"
  depends_on = [var.ssm_depends_on]
}

data "aws_ssm_parameter" "S3_ACCESS_KEY_ID" {
  name       = "/${var.application_name}/${terraform.workspace}/S3_ACCESS_KEY_ID"
  depends_on = [var.ssm_depends_on]
}
data "aws_ssm_parameter" "S3_ACCESS_SECRET_ID" {
  name       = "/${var.application_name}/${terraform.workspace}/S3_ACCESS_SECRET_ID"
  depends_on = [var.ssm_depends_on]
}
data "aws_ssm_parameter" "IAMPORT_KEY" {
  name       = "/${var.application_name}/${terraform.workspace}/IAMPORT_KEY"
  depends_on = [var.ssm_depends_on]
}
data "aws_ssm_parameter" "IAMPORT_SECRET_KEY" {
  name       = "/${var.application_name}/${terraform.workspace}/IAMPORT_SECRET_KEY"
  depends_on = [var.ssm_depends_on]
}
data "aws_ssm_parameter" "API_SECRET" {
  name       = "/${var.application_name}/${terraform.workspace}/API_SECRET"
  depends_on = [var.ssm_depends_on]
}
