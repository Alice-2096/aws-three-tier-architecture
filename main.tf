terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }

  required_version = ">= 0.14.9"
}


provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "rds" {
  source                  = "./modules/rds"
  project_name            = var.project_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_subnet_group_name    = module.vpc.database_subnet_group_name
  vpc_id                  = module.vpc.vpc_id
  private_subnets_backend = module.vpc.private_subnets_backend
  db_port                 = var.db_port
}

module "alb" {
  source                      = "./modules/alb"
  vpc_id                      = module.vpc.vpc_id
  private_subnet_frontend     = module.vpc.private_subnets_frontend
  private_subnet_backend      = module.vpc.private_subnets_backend
  private_subnet_backend_ids  = module.vpc.private_subnets_backend_ids
  private_subnet_frontend_ids = module.vpc.private_subnets_frontend_ids
  project_name                = var.project_name
}

module "ec2_in_asg" {
  source                  = "./modules/ec2_in_asg"
  vpc_id                  = module.vpc.vpc_id
  frontend_alb_ip         = module.alb.frontend_alb_ip
  backend_alb_ip          = module.alb.backend_alb_ip
  private_subnet_frontend = module.vpc.private_subnets_frontend_ids
  private_subnet_backend  = module.vpc.private_subnets_backend_ids
  db_subnet_cidr_block    = module.vpc.database_subnets_cidr_blocks
  db_port                 = module.rds.rds_port
  project_name            = var.project_name
  frontend_instance_count = var.frontend_instance_count
  backend_instance_count  = var.backend_instance_count
}



