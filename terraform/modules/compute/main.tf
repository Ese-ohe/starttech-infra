variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "starttech-backend-sg"
  description = "Backend security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "starttech-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "backend" {
  name_prefix   = "starttech-backend"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash

yum update -y
yum install -y docker

systemctl start docker
systemctl enable docker

docker pull esecloud/starttech-backend:latest

docker run -d \
  -p 8080:8080 \
  -e MONGO_URI="mongodb+srv://eseoheasuelimen_db_user:nGisaYYqr3j4bn4W@cluster0.l2itfg2.mongodb.net/starttech?retryWrites=true&w=majority&appName=Cluster0" \
  -e DB_NAME="starttech" \
  -e PORT="8080" \
  -e JWT_SECRET_KEY="mysecretkey" \
  --restart always \
  --name starttech-backend \
  esecloud/starttech-backend:latest

EOF
  )
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "starttech-backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
  }
}

resource "aws_lb" "backend_alb" {
  name               = "starttech-backend-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.backend_sg.id
  ]

  subnets = var.public_subnet_ids
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
  name                = "starttech-backend-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = var.public_subnet_ids

  target_group_arns = [
    aws_lb_target_group.backend_tg.arn
  ]

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "starttech-backend"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "starttech-scale-up"
  autoscaling_group_name = aws_autoscaling_group.backend_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "starttech-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.backend_asg.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_up.arn
  ]
}