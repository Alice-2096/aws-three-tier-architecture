output "frontend_alb_ip" {
  value = aws_alb.alb-for-frontend.dns_name
}
output "backend_alb_ip" {
  value = aws_alb.alb-for-backend.dns_name
}

