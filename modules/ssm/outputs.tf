output "DATABASE_URL" {
  value = aws_ssm_parameter.DATABASE_URL.value
}

output "APOLLO_KEY" {
  description = "Apollo secret key of Apollo Studio for API container"
  value       = aws_ssm_parameter.APOLLO_KEY.value
}

output "APOLLO_GRAPH_REF" {
  description = "Apollo Graph Ref value of Apollo Studio for API container"
  value       = aws_ssm_parameter.APOLLO_GRAPH_REF.value
}

output "S3_ACCESS_KEY_ID" {
  description = "AWS S3 Access Key ID"
  value       = aws_ssm_parameter.S3_ACCESS_KEY_ID.value
}
output "S3_ACCESS_SECRET_ID" {
  description = "AWS S3 Access Secret ID"
  value       = aws_ssm_parameter.S3_ACCESS_SECRET_ID.value
}
output "IAMPORT_KEY" {
  description = "IAMPORT Access Key"
  value       = aws_ssm_parameter.IAMPORT_KEY.value
}
output "IAMPORT_SECRET_KEY" {
  description = "IAMPORT Access Secret Key"
  value       = aws_ssm_parameter.IAMPORT_SECRET_KEY.value
}
output "API_SECRET" {
  description = "API Secret Key"
  value       = aws_ssm_parameter.API_SECRET.value
}
