output "DATABASE_URL" {
  value = data.aws_ssm_parameter.DATABASE_URL
}

output "APOLLO_KEY" {
  value = data.aws_ssm_parameter.APOLLO_KEY
}

output "APOLLO_GRAPH_REF" {
  value = data.aws_ssm_parameter.APOLLO_GRAPH_REF
}

output "S3_ACCESS_KEY_ID" {
  value = data.aws_ssm_parameter.S3_ACCESS_KEY_ID
}

output "S3_ACCESS_SECRET_ID" {
  value = data.aws_ssm_parameter.S3_ACCESS_SECRET_ID
}

output "IAMPORT_KEY" {
  value = data.aws_ssm_parameter.IAMPORT_KEY
}

output "IAMPORT_SECRET_KEY" {
  value = data.aws_ssm_parameter.IAMPORT_SECRET_KEY
}

output "API_SECRET" {
  value = data.aws_ssm_parameter.API_SECRET
}
