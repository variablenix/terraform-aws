variable "bastion_ip" {
  description = "The public IP address allowed to access the bastion host"
  type        = list(string)
}

variable "public_ip" {
  description = "The public IP address allowed to access the web server"
  type        = list(string)
}

# vpc_cidr range
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# vpc name
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "kode_vpc"
}

# subnet cidr blocks
variable "subnet1_cidr" {
  description = "The CIDR block for the first subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet2_cidr" {
  description = "The CIDR block for the second subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# subnet availability zones
variable "subnet1_az" {
  description = "The availability zone for the first subnet"
  type        = string
  default     = "us-west-1a"
}

variable "subnet2_az" {
  description = "The availability zone for the second subnet"
  type        = string
  default     = "us-west-1c"
}

# EC2 instance name
variable "instance_name" {
  description = "Web EC2 instance"
  type        = string
  default     = "kode_web_instance"
}

# EC2 instance type
variable "ec2_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# EC2 AMI ID
variable "ec2_ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-07d2649d67dbe8900"  # Ubuntu Server 24.04 LTS AMI
}