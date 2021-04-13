resource "aws_rds_cluster_parameter_group" "paramater_group" {
  name   = "cloudcasts-${var.infra_env}-pg-aurora-cluster"
  family = "aurora-mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "max_allowed_packet"
    value = "1073741824"
  }

  tags = {
    Name        = "cloudcasts ${var.infra_env} RDS Parameter Group - Aurora Cluster"
    Environment = var.infra_env
    Project     = "cloudcasts.io"
    ManagedBy   = "terraform"
    Type        = "aurora"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  # Name is used in aws_rds_cluster::db_parameter_group_name parameter
  name   = "cloudcasts-${var.infra_env}-pg-aurora"
  family = "aurora-mysql5.7"

  tags = {
    Name        = "cloudcasts ${var.infra_env} RDS Parameter Group - Aurora"
    Environment = var.infra_env
    Project     = "cloudcasts.io"
    ManagedBy   = "terraform"
    Type        = "aurora"
  }
}

# aws database subnet group
# aws rds cluster
# aws rds cluster instance
module "rds-aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "4.0.0"
  # insert the 12 required variables here

  name           = "cloudcasts-${var.infra_env}-aurora-mysql"
  engine         = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.09.2"
  instance_type  = var.instance_type

  vpc_id  = var.vpc_id
  subnets = var.subnets

  replica_count           = 1

  db_parameter_group_name         = aws_db_parameter_group.db_parameter_group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.paramater_group.name

  create_random_password = false
  username = var.master_username
  password = var.master_password

  tags = {
    Environment = var.infra_env
    Project     = "cloudcasts.io"
    ManagedBy   = "terraform"
    Type        = "aurora"
  }
}

