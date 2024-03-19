output "private_subnets_frontend" {
  value = var.vpc_private_subnets_frontend
}
output "private_subnets_backend" {
  value = var.vpc_private_subnets_backend
}
output "private_subnets_frontend_ids" {
  value = module.vpc.private_subnets
}
output "private_subnets_backend_ids" {
  value = aws_subnet.private_subnet_backend.*.id
}
output "database_subnets_cidr_blocks" {
  value = module.vpc.database_subnets_cidr_blocks
}
output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}
output "security_groups" {
  value = module.vpc.default_security_group_id
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
