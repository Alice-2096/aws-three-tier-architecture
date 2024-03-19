variable "frontend_instance_count" {
  description = "The number of instances to launch"
  type        = number
  default     = 1
}
variable "backend_instance_count" {
  description = "The number of instances to launch"
  type        = number
  default     = 1
}
# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
variable "project_name" {}
variable "vpc_id" {}
variable "frontend_alb_ip" {}
variable "backend_alb_ip" {}
variable "private_subnet_frontend" {}
variable "private_subnet_backend" {}
variable "db_port" {}
variable "db_subnet_cidr_block" {}

