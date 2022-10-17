variable "application_name" {
  description = "Application name"
}

variable "random_id_prefix" {
  description = "random prefix"
}

variable "subnet_ids" {
  type        = list(any)
  description = "Subnet ids"
}

variable "global_cluster_identifier" {
  description = "global cluster identifier"
}

variable "cluster_identifier" {
  description = "cluster identifier"
}

variable "replication_source_identifier" {
  description = "replication source identifier"
}

variable "source_region" {
  description = "source region"
}

variable "engine" {
  description = "engine"
}

variable "engine_mode" {
  description = "engine mode"
}

variable "database_name" {
  description = "database name"
}

variable "master_username" {
  description = "master username"
}

variable "vpc_security_group_ids" {
  description = "vpc security group ids"
}

variable "db_cluster_parameter_group_name" {
  description = "db cluster parameter group name"
}

variable "final_snapshot_identifier" {
  description = "final snapshot identifier"
}

variable "backup_retention_period" {
  description = "backup retention period"
}

variable "preferred_backup_window" {
  description = "preferred backup window"
}

variable "preferred_maintenance_window" {
  description = "preferred maintenance window"
}

variable "skip_final_snapshot" {
  description = "skip final snapshot"
}

variable "storage_encrypted" {
  description = "storage encrypted"
}

variable "apply_immediately" {
  description = "apply immediately"
}

variable "iam_database_authentication_enabled" {
  description = "iam database authentication enabled"
}

variable "backtrack_window" {
  description = "backtrack window"
}

variable "copy_tags_to_snapshot" {
  description = "copy tags to snapshot"
}

variable "deletion_protection" {
  description = "deletion protection"
}

variable "auto_pause" {
  description = "auto pause"
}

variable "max_capacity" {
  description = "max capacity"
}

variable "min_capacity" {
  description = "min capacity"
}

variable "seconds_until_auto_pause" {
  description = "seconds until auto pause"
}

variable "api_server_sg" {
  description = "API server security group"
}

variable "vpc_id" {
  description = "vpc id"
}
