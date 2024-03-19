variable "vpc_id" {}
variable "private_subnet_frontend" {
  type = list(string)
}
variable "private_subnet_backend" {
  type = list(string)
}
variable "project_name" {}
variable "private_subnet_frontend_ids" {

}
variable "private_subnet_backend_ids" {

}
variable "frontend_ec2_ips" {

}
variable "backend_ec2_ips" {

}
