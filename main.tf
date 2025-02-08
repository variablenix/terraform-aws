# Create a Key Pair
resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.deployer.public_key_openssh
}

resource "local_file" "private_key" {
  content        = tls_private_key.deployer.private_key_pem
  filename       = "${path.module}/tf-key-pair.pem"
  file_permission = "0400"
}

# Create a VPC
resource "aws_vpc" "kode_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "kode_igw" {
  vpc_id = aws_vpc.kode_vpc.id

  tags = {
    Name = "kode-igw"
  }
}

# Create a Route Table
resource "aws_route_table" "kode_rt" {
  vpc_id = aws_vpc.kode_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kode_igw.id
  }

  tags = {
    Name = "kode-route-table"
  }
}

# Associate the Route Table with the Subnets
resource "aws_route_table_association" "kode_rta_1" {
  subnet_id      = aws_subnet.kode_subnet_1.id
  route_table_id = aws_route_table.kode_rt.id
}

resource "aws_route_table_association" "kode_rta_2" {
  subnet_id      = aws_subnet.kode_subnet_2.id
  route_table_id = aws_route_table.kode_rt.id
}

# Create Subnets CIDR Blocks
resource "aws_subnet" "kode_subnet_1" {
  vpc_id            = aws_vpc.kode_vpc.id
  cidr_block        = var.subnet1_cidr
  availability_zone = var.subnet1_az
}

resource "aws_subnet" "kode_subnet_2" {
  vpc_id            = aws_vpc.kode_vpc.id
  cidr_block        = var.subnet2_cidr
  availability_zone = var.subnet2_az
}

# Create a Bastion Host
resource "aws_instance" "bastion" {
  ami           = var.ec2_ami # Reference the variable
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.kode_subnet_1.id
  key_name      = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost"
  }
}

# Create an Application Load Balancer
resource "aws_lb" "kode_alb" {
  name               = "kode-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.kode_sg.id]
  subnets            = [
    aws_subnet.kode_subnet_1.id,
    aws_subnet.kode_subnet_2.id
  ]

  enable_deletion_protection = false
}

# Create a Target Group
resource "aws_lb_target_group" "kode_tg" {
  name     = "kode-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.kode_vpc.id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-304"
  }
}

# Register the EC2 Instances with the Target Group
resource "aws_lb_target_group_attachment" "kode_tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.kode_tg.arn
  target_id        = aws_instance.kode_web[count.index].id
  port             = 80
}

# Create a Listener
resource "aws_lb_listener" "kode_listener" {
  load_balancer_arn = aws_lb.kode_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kode_tg.arn
  }
}

# Create Web EC2 Instances
resource "aws_instance" "kode_web" {
  count         = 2
  ami           = "ami-07d2649d67dbe8900" # Ubuntu Server 24.04 LTS AMI
  instance_type = "var.ec2_instance_type"
  subnet_id     = aws_subnet.kode_subnet_1.id
  vpc_security_group_ids = [aws_security_group.kode_sg.id]
  key_name      = aws_key_pair.my_key_pair.key_name  # key pair name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash -ex

              apt-get update -y
              apt-get install nginx -y

              # Replace the default Nginx HTML file
              echo '<html>
              <head><title>Klein's Custom Nginx Page</title></head>
              <body><h1>Hello, World from Terraform!</h1></body>
              </html>' > /var/www/html/index.nginx-debian.html

              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = var.instance_name
  }
}