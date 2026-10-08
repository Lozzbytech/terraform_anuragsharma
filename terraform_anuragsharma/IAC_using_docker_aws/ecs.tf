#create cluster, sets execution role and task role logging/pulling tasks, and provisions backend and frontend services inside isolated fargate cluster
resource "aws_ecs_cluster" "main" {
  name = "ares-ecs-cluster"
}

#task execution role for ecs tasks to pull images from ecr and send logs to cloudwatch
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ares-ecs-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            },
        ]
    })
}   
resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#container networking protection structures
resource "aws_security_group" "ecs_task_sg" {
  name_prefix = "ares-ecs-task-sg"
  description = "Allow inbound traffic from ALB to ECS tasks"
  vpc_id      = aws_vpc.ares_vpc.id

  ingress {
  from_port   = 3000 
  to_port     = 3000
  protocol    = "tcp"
  security_groups = [aws_security_group.lb_sg.id]
  }
  ingress {
  from_port   = 5000
  to_port     = 5000
  protocol    = "tcp"
  security_groups = [aws_security_group.lb_sg.id]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ares-ecs-task-sg"
  }
}
#backend task & service definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "ares-backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn   

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
    }
  ])
}
resource "aws_ecs_service" "backend" {
  name            = "ares-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on = [null_resource.build_and_push]

  force_new_deployment = true
  network_configuration {
    subnets         = [aws_subnet.pub_a.id, aws_subnet.pub_b.id]
    security_groups = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 5000
  }
  }
#frontend task & service definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "ares-frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${aws_ecr_repository.frontend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "ares-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on = [null_resource.build_and_push]

  force_new_deployment = true

  network_configuration {
    subnets          = [aws_subnet.pub_a.id, aws_subnet.pub_b.id]
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 3000
  }
}