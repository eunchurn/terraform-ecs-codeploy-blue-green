
# Security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.random_id_prefix}-${var.application_name}-${terraform.workspace}-alb-sg"
  description = "Application Load Balancer Security Group"
  vpc_id      = var.vpc_id

  ingress = [{
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow HTTP Access On Port 80"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    },
    {
      description      = "TLS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      from_port        = 8000
      to_port          = 8000
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow HTTP Access On Port 8080"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      from_port        = 8
      to_port          = 0
      protocol         = "icmp"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow Ping"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
  }]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.random_id_prefix}-${var.application_name}-${terraform.workspace}-alb-sg"
  }
}

# ECS Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "${var.random_id_prefix}-${var.application_name}-${terraform.workspace}-ecs-sg"
  vpc_id      = var.vpc_id
  description = "ECS Task Security Group Allow egress from container"

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.random_id_prefix}-${var.application_name}-${terraform.workspace}-ecs-sg"
    Environment = "${terraform.workspace}"
  }
}
