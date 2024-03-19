
output "frontend_ec2_ips" {
  value = aws_instance.frontend[*].private_ip
}
output "backend_ec2_ips" {
  value = aws_instance.backend[*].private_ip
}
