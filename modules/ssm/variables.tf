variable "application_name" {
  description = "Application name"
}

variable "random_id_prefix" {
  description = "random prefix"
}

variable "rds_depend_on" {
  description = "RDS depend on"
}

variable "APOLLO_KEY" {
  description = "Apollo secret key of Apollo Studio for API container"
  type        = string
  sensitive   = true
}

variable "APOLLO_GRAPH_REF" {
  description = "Apollo Graph Ref value of Apollo Studio for API container"
  type        = string
  sensitive   = false
}

variable "S3_ACCESS_KEY_ID" {
  description = "AWS S3 Access Key ID"
  type        = string
  sensitive   = true
}
variable "S3_ACCESS_SECRET_ID" {
  description = "AWS S3 Access Secret ID"
  type        = string
  sensitive   = true
}
variable "IAMPORT_KEY" {
  description = "IAMPORT Access Key"
  type        = string
  sensitive   = true
}
variable "IAMPORT_SECRET_KEY" {
  description = "IAMPORT Access Secret Key"
  type        = string
  sensitive   = true
}
variable "API_SECRET" {
  description = "API Secret Key"
  type        = string
  sensitive   = true
}
