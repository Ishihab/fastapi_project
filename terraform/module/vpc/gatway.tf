resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "my-igw"
    Environment = "dev" 
  }
  
}

resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public_subnet
  depends_on = [ aws_internet_gateway.igw ]
  
}

resource "aws_nat_gateway" "nat_gw" {
  for_each = aws_subnet.public_subnet
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id
  tags = {
    Name = "nat-gateway-${each.key}"
    Environment = "dev" 
  }
  
}