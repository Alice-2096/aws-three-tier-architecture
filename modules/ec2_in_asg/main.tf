////////////////////// security group ////////////////////////
resource "aws_security_group" "frontend" {
  name_prefix = var.project_name
  description = "Allow inbound traffic from ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.frontend_alb_ip]
  }
  egress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.backend_alb_ip]
  }
}

resource "aws_security_group" "backend" {
  name_prefix = var.project_name
  description = "Allow inbound traffic from backend ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.backend_alb_ip]
  }
  egress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.db_subnet_ip]
  }
}


////////////////////// EC2 instance //////////////////////// 
resource "aws_instance" "frontend" {
  count         = var.frontend_instance_count
  ami           = var.frontend_ami_id
  instance_type = "t3.micro"

  tags = {
    Name = "frontend-${count.index + 1}"
  }
  security_groups = [aws_security_group.frontend.id]
  user_data       = file("user-data.sh")
}

resource "aws_instance" "backend" {
  count         = var.backend_instance_count
  ami           = var.backend_ami_id
  instance_type = "t3.micro"

  tags = {
    Name = "backend-${count.index + 1}"
  }
  security_groups = [aws_security_group.backend.id]
  user_data       = file("user-data.sh")
}

////////////////////// launch configuration ////////////////////////
# ASG requires a launch configuration to launch instances in the group.
resource "aws_launch_configuration" "frontend-launch_configuration" {
  name_prefix     = var.project_name
  image_id        = var.frontend_ami_id
  instance_type   = "t2.micro"
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.frontend.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "backend-launch_configuration" {
  name_prefix     = var.project_name
  image_id        = var.backend_ami_id
  instance_type   = "t2.micro"
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.backend.id]

  lifecycle {
    create_before_destroy = true
  }
}

////////////////////// Auto Scaling Group ////////////////////////
resource "aws_autoscaling_group" "frontend" {
  desired_capacity     = var.frontend_instance_count
  max_size             = var.frontend_instance_count
  min_size             = var.frontend_instance_count
  launch_configuration = aws_launch_configuration.frontend-launch_configuration.id
  vpc_zone_identifier  = var.private_subnet_frontend
}

resource "aws_autoscaling_group" "backend" {
  desired_capacity     = var.backend_instance_count
  max_size             = var.backend_instance_count
  min_size             = var.backend_instance_count
  launch_configuration = aws_launch_configuration.backend-launch_configuration.id
  vpc_zone_identifier  = var.private_subnet_backend
}

////////////////////// outputs ////////////////////////
output "frontend_instance_id" {
  value = aws_instance.frontend[*].id
}
output "backend_instance_id" {
  value = aws_instance.backend[*].id
}