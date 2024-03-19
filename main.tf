terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.38.0"
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

module "alb" {
  source                  = "./modules/alb"
  vpc_id                  = module.vpc.vpc_id
  private_subnet_frontend = module.vpc.private_subnet_ids
  private_subnet_backend  = module.vpc.private_subnet_ids
  project_name            = var.project_name
}



