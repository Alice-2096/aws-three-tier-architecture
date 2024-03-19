resource "aws_db_instance" "rds_instance" {
  identifier           = "${var.project_name}-rds"
  instance_class       = "db.t3.micro"
  allocated_storage    = 5
  port                 = 5432
  engine               = "postgres"
  engine_version       = "14.8"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = var.db_subnet_group_name

  vpc_security_group_ids = [aws_security_group.rds.id]
  #   parameter_group_name   = aws_db_parameter_group.parameter_group.name
  publicly_accessible = false
  skip_final_snapshot = true
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for ${var.project_name} RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.private_subnets_backend
  }
}

# Database parameters specify how the database is configured, e.g., the amount of resources like memory 

# resource "aws_db_parameter_group" "parameter_group" {
#   name        = "${var.project_name}-rds-parameter-group"
#   family      = "postgres14"
#   description = "Custom parameter group for ${var.project_name} RDS"

#   parameter {
#     name  = "shared_preload_libraries"
#     value = "pg_stat_statements"
#   }
#   parameter {
#     name  = "log_statement"
#     value = "all"
#   }
# }
