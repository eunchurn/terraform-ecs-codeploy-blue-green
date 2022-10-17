# master password
resource "random_password" "master_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "rds-db-credentials/${var.application_name}/${terraform.workspace}/${var.random_id_prefix}"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.application_name}-${terraform.workspace}-${var.random_id_prefix}-db_subnet_group"
  subnet_ids = flatten(["${var.subnet_ids}"])

  tags = {
    Name = "${var.application_name}-${terraform.workspace}-${var.random_id_prefix}-db_subnet_group"
  }
}

# Security Group for resources that want to access the Database
resource "aws_security_group" "db_access_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.application_name}-${terraform.workspace}-db-access-sg"
  description = "Allow access to DocumentDB"

  tags = {
    Name        = "${var.application_name}-${terraform.workspace}-db-access-sg"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_security_group" "rdsdb_sg" {
  name        = "${var.application_name}-${terraform.workspace}-rdsdb-sg"
  description = "${var.application_name}-${terraform.workspace} RDS PostgreSQL aurora serverless Security Group"
  vpc_id      = var.vpc_id
  tags = {
    Name        = "${var.application_name}-${terraform.workspace}-rdsdb-sg"
    Environment = "${terraform.workspace}"
  }

  # allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # allow traffic for TCP 5432
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.db_access_sg.id}"]
  }
  # allow traffic for TCP 5432 from API Container
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${var.api_server_sg}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_rds_cluster_parameter_group" "default" {
  name = "${var.application_name}-${terraform.workspace}-${var.random_id_prefix}-rds-cluster-pg"
  /**
     * 서울 리전 버전 체크
     * aws rds describe-db-engine-versions | jq '.DBEngineVersions[] | select(.SupportedEngineModes != null and .SupportedEngineModes[] == "serverless" and .Engine == "aurora-postgresql")'
     * */
  family      = "aurora-postgresql10"
  description = "RDS default cluster parameter group"
}

resource "aws_rds_cluster" "this" {
  cluster_identifier                  = var.cluster_identifier
  source_region                       = var.source_region
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  database_name                       = var.database_name
  master_username                     = var.master_username
  master_password                     = random_password.master_password.result
  final_snapshot_identifier           = var.final_snapshot_identifier
  skip_final_snapshot                 = var.skip_final_snapshot
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids              = ["${aws_security_group.rdsdb_sg.id}"]
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.default.id
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backtrack_window                    = var.backtrack_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  deletion_protection                 = var.deletion_protection

  scaling_configuration {
    auto_pause               = var.auto_pause
    max_capacity             = var.max_capacity
    min_capacity             = var.min_capacity
    seconds_until_auto_pause = var.seconds_until_auto_pause
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags = {
    Name = "${var.application_name}-${terraform.workspace} RDS Cluster"
  }
}

# Secret value update https://stackoverflow.com/a/67927860
resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    "username" : "${aws_rds_cluster.this.master_username}",
    "password" : "${random_password.master_password.result}",
    "engine" : "${aws_rds_cluster.this.engine}",
    "host" : "${aws_rds_cluster.this.endpoint}",
    "port" : "${aws_rds_cluster.this.port}",
    "dbClusterIdentifier" : "${aws_rds_cluster.this.cluster_identifier}"
  })
}


