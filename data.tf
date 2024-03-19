
# data "aws_network_interface" "lb" {
#   for_each = module.vpc.private_subnets_frontend_ids
#   filter {
#     name   = "description"
#     values = ["frontend-alb"]
#   }

#   filter {
#     name   = "subnet-id"
#     values = [each.value]
#   }
# }
