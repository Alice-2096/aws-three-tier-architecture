//////////////////////// security group for alb ////////////////////////
resource "aws_security_group" "sg-for-frontend_alb" {
  name        = "alb-sg-frontend"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  egress { # allow traffic to frontend subnet only
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_frontend
  }

  ingress { # allow HTTP traffic from anywhere 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # allow HTTPS traffic from anywhere 
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg-for-backend_alb" {
  name   = "alb-sg-backend"
  vpc_id = var.vpc_id

  ingress { # only allow traffic from the frontend security group on port 3000 
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-for-frontend_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_frontend
  }
}

//////////////////////// alb ////////////////////////
resource "aws_alb" "alb-for-frontend" {
  name               = "${var.project_name}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.private_subnet_frontend_ids # frontend subnet ids 
  security_groups    = [aws_security_group.sg-for-frontend_alb.id]
}

resource "aws_alb" "alb-for-backend" {
  name               = "${var.project_name}-backend-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.private_subnet_backend_ids
  security_groups    = [aws_security_group.sg-for-backend_alb.id]
}

//////////////////////// target group ////////////////////////
resource "aws_lb_target_group" "target_group_frontend" {
  name        = "${var.project_name}-target-group-frontend"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "80"
    interval = 10
  }
}

resource "aws_lb_target_group" "target_group_backend" {
  name        = "${var.project_name}-target-group-backend"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "3000"
    interval = 10
  }
}


resource "aws_lb_target_group_attachment" "tg_attachment_frontend" {
  count            = length(var.frontend_ec2_ips)
  target_group_arn = aws_lb_target_group.target_group_frontend.arn
  target_id        = var.frontend_ec2_ips[count.index]
}

resource "aws_lb_target_group_attachment" "tg_attachment_backend" {
  count            = length(var.backend_ec2_ips)
  target_group_arn = aws_lb_target_group.target_group_backend.arn
  target_id        = var.backend_ec2_ips[count.index]
}

//////////////////////// listener ////////////////////////
resource "aws_lb_listener" "listener_frontend" {
  depends_on        = [aws_lb_target_group.target_group_frontend]
  load_balancer_arn = aws_alb.alb-for-frontend.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_frontend.arn
  }
}

resource "aws_lb_listener" "listener_redirect_http_traffic" {
  depends_on        = [aws_lb_target_group.target_group_frontend]
  load_balancer_arn = aws_alb.alb-for-frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "listener_backend" {
  depends_on        = [aws_lb_target_group.target_group_backend]
  load_balancer_arn = aws_alb.alb-for-backend.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_backend.arn
  }
}
