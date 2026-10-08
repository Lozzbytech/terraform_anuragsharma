# 1. custom isolated networking (vpc setup)
resource "aws_vpc" "ares_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ares-multi-tier-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ares_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ares-public-subnet"
  }
}

resource "aws_internet_gateway" "ares_igw" {
  vpc_id = aws_vpc.ares_vpc.id
  tags = {
    Name = "ares-gateway"
  }
}

resource "aws_route_table" "ares_route_table" {
  vpc_id = aws_vpc.ares_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ares_igw.id
  }
  tags = {
    Name = "ares-route-table"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.ares_route_table.id
}

# 2. firewall rules - frontend security group (port 3000 & 22)
resource "aws_security_group" "frontend_sg" {
  name_prefix = "ares-frontend-sg"
  description = "Allow public access on port 3000 and SSH access on port 22"
  vpc_id      = aws_vpc.ares_vpc.id
ingress {
    from_port   = 3000
    to_port     = 3000
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

# 3. firewall rules - backend security group (port 5000 & 22)
resource "aws_security_group" "backend_sg" {
  name_prefix =          "ares-backend-sg"
  description = "Allow cross-communication access on port 5000 and SSH access on port 22"
  vpc_id      = aws_vpc.ares_vpc.id

ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
#allow inbound calls on port 5000 from the frontend security group
ingress {
  from_port       = 5000
  to_port         = 5000
  protocol        = "tcp"
  security_groups = [aws_security_group.frontend_sg.id]

}

#allow external direct access to the backend server on port 5000 for testing purposes
ingress {
  from_port   = 5000
  to_port     = 5000
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

# 4. provision separate servers
#backend server
resource "aws_instance" "backend_server" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name              = "ares"

  # Links the external script and maps the git URL argument variable
  user_data = templatefile("${path.module}/setup_backend.sh", {
    REPO_URL = var.repo_url
  })

  tags = {
    Name = "Ares-backend-server"
  }
}

#frontend server
resource "aws_instance" "frontend_server" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  key_name              = "ares"

  user_data = templatefile("${path.module}/setup_frontend.sh", {
    REPO_URL = var.repo_url
    BACKEND_IP = aws_instance.backend_server.public_ip
  })

  tags = {
    Name = "Ares-frontend-server"
  }
}
