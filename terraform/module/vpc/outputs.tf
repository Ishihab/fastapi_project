output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
  
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public_subnet[*].id
  
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private_subnets[*].id
  
}

output "subnets_eks" {
    description = "The IDs of the subnets for EKS"
    value       = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnets[*].id)
  
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.db_subnet_group.name
  
}

output "db_sg_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db_sg.id
}

