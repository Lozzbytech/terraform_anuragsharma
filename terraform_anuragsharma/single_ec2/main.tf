# 1. Network Firewall Policy Rules
resource "aws_security_group" "app_sg" {
  name        = "ares-split-sg"
  description = "Allow custom traffic for Ares application ecosystem"

  # Access for Express Frontend
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Access for Flask Backend
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule to download packages
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# 2. Create the EC2 computational server
resource "aws_instance" "web_server" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name              = "ares"

  # Links the external script and maps the git URL argument variable
  user_data = templatefile("${path.module}/setup.sh", {
    REPO_URL = var.repo_url
  })

  tags = {
    Name = "Ares-Modular-Server"
  }
}


