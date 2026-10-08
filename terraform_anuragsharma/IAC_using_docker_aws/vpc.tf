#custom vpc, subnet, internet gateway, route table
resource "aws_vpc" "ares_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ares-ecs-vpc"
  }
}

resource "aws_subnet" "pub_a" {
  vpc_id                  = aws_vpc.ares_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ares-public-subnet-a"
  }
}

resource "aws_subnet" "pub_b" {
  vpc_id                  = aws_vpc.ares_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "ares-public-subnet-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ares_vpc.id
  tags = {
    Name = "ares-gateway"
  }
}

resource "aws_route_table" "ares_route_table" {
  vpc_id = aws_vpc.ares_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "ares-route-table"
  }
}
resource "aws_route_table_association" "pub_a_assoc" {
  subnet_id      = aws_subnet.pub_a.id
  route_table_id = aws_route_table.ares_route_table.id
}
resource "aws_route_table_association" "pub_b_assoc" {
  subnet_id      = aws_subnet.pub_b.id
  route_table_id = aws_route_table.ares_route_table.id
}