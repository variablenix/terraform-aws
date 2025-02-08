# Output the ID of the VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.kode_vpc.id
}

# Output the ID of the EC2 instances
output "instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.kode_web[*].id
}

# Output the DNS name of the Application Load Balancer
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.kode_alb.dns_name
}

# Output the public IP addresses of the EC2 instances
output "instance_public_ips" {
  description = "The public IP addresses of the EC2 instances"
  value       = [for instance in aws_instance.kode_web : instance.public_ip]
}

# Output the ARN of the Target Group
output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.kode_tg.arn
}

