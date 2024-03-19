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
variable "frontend_ami_id" {
  default = "ami-0e0bf53f6def86294"
}
variable "backend_ami_id" {
  default = "ami-0e0bf53f6def86294"
}
variable "project_name" {}
variable "vpc_id" {}
variable "frontend_alb_ip" {}
variable "backend_alb_ip" {}
variable "private_subnet_frontend" {}
variable "private_subnet_backend" {}
variable "db_subnet_ip" {}
variable "db_port" {}
