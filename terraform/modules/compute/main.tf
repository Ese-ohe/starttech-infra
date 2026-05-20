resource "aws_security_group" "backend_sg" {
  name        = "starttech-backend-sg"
  description = "Security group for backend"
  vpc_id      = "vpc-123456"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "starttech-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_launch_template" "backend_template" {
  name_prefix   = "starttech-template"
  image_id      = "ami-12345678"
  instance_type = "t2.micro"
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "starttech-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "vpc-123456"
}

resource "aws_lb" "backend_alb" {
  name               = "starttech-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_sg.id]
  subnets            = ["subnet-123456", "subnet-654321"]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  vpc_zone_identifier = [
    "subnet-123456",
    "subnet-654321"
  ]

  launch_template {
    id      = aws_launch_template.backend_template.id
    version = "$Latest"
  }
}