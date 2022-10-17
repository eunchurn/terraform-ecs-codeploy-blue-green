variable "s3_terraform_state_bucket_name" {
  description = "S3 Terraform state bucket name"
}

variable "s3_terraform_state_key" {
  description = "S3 Terraform state key"
}

variable "dynamodb_terraform_state_locks_table" {
  description = "DynamoDB Terraform state locks table"
}
