resource "aws_security_group" "lb_sg" {
  name        = "ares-alb-sg"
  description = "Security group for Ares Load Balancer"
  vpc_id      = aws_vpc.ares_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
    tags = {
        Name = "ares-alb-sg"
    }
    }
resource "aws_lb" "main" {
  name               = "ares-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.pub_a.id, aws_subnet.pub_b.id]
  

  tags = {
    Name = "ares-loadbalancer"
  }
}
#target routing pool category frontend
resource "aws_lb_target_group" "frontend" {
  name     = "tg-ares-frontend"
  port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.ares_vpc.id
    target_type = "ip"
    health_check {
        path                = "/"
}
}
#target routing pool category backend
resource "aws_lb_target_group" "backend" {
  name     = "tg-ares-backend"
  port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.ares_vpc.id
    target_type = "ip"
    health_check {
        path                = "/api/message"
    }
}
#layer 7 http traffic ingress policy configuration for frontend and backend target groups
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.frontend.arn
    }
}
resource "aws_lb_listener_rule" "api_routing" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  } 
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}