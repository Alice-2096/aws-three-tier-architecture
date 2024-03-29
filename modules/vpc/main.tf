
# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  # VPC Basic Details
  name                         = var.vpc_name
  cidr                         = var.vpc_cidr_block
  azs                          = var.vpc_availability_zones
  public_subnets               = var.vpc_public_subnets
  private_subnets              = var.vpc_private_subnets_frontend
  database_subnets             = var.database_subnets
  create_database_subnet_group = var.vpc_create_database_subnet_group

  map_public_ip_on_launch = true

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  enable_dhcp_options = true

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags     = local.common_tags
  vpc_tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type                    = "Public Subnets"
    map_public_ip_on_launch = true
  }
  private_subnet_tags = {
    Type = "Private Subnets"
  }
}

resource "aws_subnet" "private_subnet_backend" {
  count                   = length(var.vpc_private_subnets_backend)
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.vpc_private_subnets_backend[count.index]
  availability_zone       = var.vpc_availability_zones[count.index]
  map_public_ip_on_launch = false
  tags                    = { Type = "Private Subnets backend" }
}

resource "aws_route_table" "private_route_table_backend" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "Private Route Table for Backend"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.natgw_ids[0]
  }
}

resource "aws_route_table_association" "private_subnet_association_backend" {
  count          = length(var.vpc_private_subnets_backend)
  subnet_id      = aws_subnet.private_subnet_backend[count.index].id
  route_table_id = aws_route_table.private_route_table_backend.id
}

locals {
  common_tags = {
    Owner       = var.owner
    Environment = var.environment
  }
}



