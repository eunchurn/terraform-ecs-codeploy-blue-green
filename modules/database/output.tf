output "aws_rds_cluster_endpoint" {
  value = aws_rds_cluster.this.endpoint
}

output "aws_rds_cluster_database_name" {
  value = aws_rds_cluster.this.database_name
}

output "aws_rds_cluster_master_username" {
  value = aws_rds_cluster.this.master_username
}

output "aws_rds_cluster_credentials" {
  value = aws_secretsmanager_secret_version.rds_credentials.secret_string
}

output "aws_rds_access_security_group_ids" {
  value = aws_security_group.db_access_sg.id
}

output "aws_rds_db_security_group_ids" {
  value = aws_security_group.rdsdb_sg.id
}
