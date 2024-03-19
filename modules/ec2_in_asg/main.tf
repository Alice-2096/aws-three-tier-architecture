////////////////////// security group ////////////////////////
resource "aws_security_group" "frontend" {
  name_prefix = var.project_name
  description = "Allow inbound traffic from ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # cidr_blocks = [var.frontend_alb_ip] 
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    # cidr_blocks = [var.backend_alb_ip]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443 # connection to SSM endpoints
    to_port   = 443
    protocol  = "tcp"
    # cidr_blocks = [var.backend_alb_ip]
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend" {
  name_prefix = var.project_name
  description = "Allow inbound traffic from backend ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    # cidr_blocks = [var.backend_alb_ip]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.db_subnet_cidr_block
  }
  egress {
    from_port   = 443 # connection to SSM endpoints
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


////////////////////// EC2 instance //////////////////////// 
resource "aws_instance" "frontend" {
  count         = var.frontend_instance_count
  ami           = data.aws_ami.linux2.id
  instance_type = "t3.micro"
  subnet_id     = var.private_subnet_frontend[count.index]

  tags = {
    Name = "frontend-${count.index + 1}"
  }
  iam_instance_profile   = aws_iam_instance_profile.ec2-iam-profile.name
  vpc_security_group_ids = [aws_security_group.frontend.id]
  user_data              = file("user-data.sh")
}

resource "aws_instance" "backend" {
  count         = var.backend_instance_count
  ami           = data.aws_ami.linux2.id
  instance_type = "t3.micro"
  subnet_id     = var.private_subnet_backend[count.index]

  tags = {
    Name = "backend-${count.index + 1}"
  }
  iam_instance_profile   = aws_iam_instance_profile.ec2-iam-profile.name
  vpc_security_group_ids = [aws_security_group.backend.id]
  user_data              = file("user-data.sh")
}

////////////////////// launch configuration ////////////////////////
# ASG requires a launch configuration to launch instances in the group.
resource "aws_launch_configuration" "frontend-launch_configuration" {
  name_prefix     = var.project_name
  image_id        = data.aws_ami.linux2.id
  instance_type   = "t2.micro"
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.frontend.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "backend-launch_configuration" {
  name_prefix     = var.project_name
  image_id        = data.aws_ami.linux2.id
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

////////////////////// IAM for EC2 ////////////////////////
resource "aws_iam_instance_profile" "ec2-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2-iam-role.name
}

resource "aws_iam_role" "ec2-iam-role" {
  name               = "dev-ssm-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
  "Effect": "Allow",
  "Principal": {"Service": "ec2.amazonaws.com"},
  "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.ec2-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
