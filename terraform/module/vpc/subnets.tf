data "aws_availability_zones" "available" {
    state = "available"
}

locals {
    azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_subnet" "private_subnets" {
    for_each = toset(local.azs)
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = cidrsubnet(var.vpc_cidr, 4, index(local.azs, each.value) + 1)
    availability_zone = each.value
    map_public_ip_on_launch = false
    tags = {
        Name = "private-subnet-${each.value}"
        Environment = "dev" 
    }
  
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.vpc.id
    for_each = toset(local.azs)
    cidr_block = cidrsubnet(var.vpc_cidr, 4, index(local.azs, each.value) + length(local.azs) * 2 + 1)
    availability_zone = each.value
    map_public_ip_on_launch = true
    tags = {
        kubernetes.io/role/elb = 1
        Name = "public-subnet-${each.value}"
    }

}

resource "aws_subnet" "db_subnet" {
    for_each = toset(local.azs)
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 4, index(local.azs, each.value) + length(local.azs) + 1)
    availability_zone = local.azs[0]
    map_public_ip_on_launch = false
    tags = {
        Name = "db-subnet-${local.azs[0]}"
        Environment = "dev" 
    }
  
}

resource "aws_db_subnet_group" "db_subnet_group" {
    name       = "db-subnet-group"
    subnet_ids = [for subnet in aws_subnet.db_subnet : subnet.id]
    tags = {
        Name = "db-subnet-group"
        Environment = "dev" 
    }
  
}