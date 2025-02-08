# Define the Target Group for SSH
resource "aws_lb_target_group" "ssh_target_group" {
  name     = "ssh-tg"
  port     = 22
  protocol = "TCP"
  vpc_id   = aws_vpc.kode_vpc.id

  health_check {
    port                = "22"
    protocol            = "TCP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# Security Group for the Load Balancer
resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.kode_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["70.175.32.184/32"]  # my public IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the Load Balancer for SSH
resource "aws_lb" "ssh_lb" {
  name               = "ssh-lb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [
    aws_subnet.kode_subnet_1.id,
    aws_subnet.kode_subnet_2.id
  ]

  enable_deletion_protection = false
}

# Create a Listener for SSH
resource "aws_lb_listener" "ssh_listener" {
  load_balancer_arn = aws_lb.ssh_lb.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ssh_target_group.arn
  }
}

# Register the EC2 Instances with the SSH Target Group
resource "aws_lb_target_group_attachment" "ssh_tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.ssh_target_group.arn
  target_id        = aws_instance.kode_web[count.index].id
  port             = 22
}

# Register the First EC2 Instance with the SSH Target Group
#resource "aws_lb_target_group_attachment" "ssh_tg_attachment" {
#  target_group_arn = aws_lb_target_group.ssh_target_group.arn
#  target_id        = aws_instance.kode_web[0].id  # Register only the first instance
#  port             = 22
#}