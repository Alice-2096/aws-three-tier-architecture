# ACM Module - To create and Verify SSL Certificates
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.0"

  domain_name = trimsuffix(data.aws_route53_zone.domain.name, ".")
  zone_id     = data.aws_route53_zone.domain.zone_id

  subject_alternative_names = [
    "*.nyuvipal.com"
  ]

  # Validation Method
  validation_method   = "DNS"
  wait_for_validation = true
}

