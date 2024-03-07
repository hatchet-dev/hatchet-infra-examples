# Define the ECS cluster
resource "aws_ecs_cluster" "hatchet" {
  name = "hatchet-cluster"
}

# Create an IAM role for the ECS service
resource "aws_iam_role" "ecs_service_role" {
  name = "ecs_service_role"

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

# Attach the necessary policy to the IAM role
resource "aws_iam_role_policy_attachment" "ecs_service_policy_attachment" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Define an ECS task definition
resource "aws_ecs_task_definition" "hatchet_worker" {
  family                   = "hatchet"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_service_role.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "hatchet-worker"
      image     = var.container_image_url
      cpu       = 256
      memory    = 512
      essential = true

      environment = [
        {
          name  = "HATCHET_CLIENT_TOKEN"
          value = var.hatchet_token
        }
      ]


      # we don't need any port mappings as this is a private worker
      portMappings = []
    },
  ])
}

# Define the ECS service
resource "aws_ecs_service" "hatchet_worker" {
  name            = "hatchet-worker"
  cluster         = aws_ecs_cluster.hatchet.id
  task_definition = aws_ecs_task_definition.hatchet_worker.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.security_group.id]
    assign_public_ip = false
  }

  desired_count = 2
}
