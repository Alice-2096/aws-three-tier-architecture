# Get DNS information from AWS Route53
data "aws_route53_zone" "domain" {
  name = var.domain_name
}
