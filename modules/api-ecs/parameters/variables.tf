variable "application_name" {
  description = "Application name"
}

variable "ssm_depends_on" {
  type    = any
  default = []
}
