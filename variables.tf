variable "project_name" {

}
variable "region" {

}
variable "db_password" {

}
variable "db_username" {

}
variable "db_port" {
  default = 3306
}
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
variable "domain_name" {
  description = "The domain name to use for the DNS zone"
  type        = string
}
