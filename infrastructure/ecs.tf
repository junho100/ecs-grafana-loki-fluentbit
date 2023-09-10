################################################################################
# ECS Cluster
################################################################################

resource "aws_ecs_cluster" "cluster" {
  name = "${local.global_name_prefix}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

################################################################################
# Task Definitions
################################################################################

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${local.global_name_prefix}-grafana-task-def"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 512
  memory                   = 512
  requires_compatibilities = ["EC2"]
  container_definitions    = data.template_file.grafana.rendered
}

################################################################################
# Services
################################################################################

resource "aws_ecs_service" "grafana" {
  name            = "${local.global_name_prefix}-grafana-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "EC2"


  network_configuration {
    subnets = module.vpc.private_subnets
  }

  depends_on = [aws_lb_listener.https_forward, aws_lb_listener.http_forward, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

################################################################################
# Supporting Resources
################################################################################

data "template_file" "grafana" {
  template = file("./grafana.tftpl")
}

module "autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${local.global_name_prefix}-asg"

  image_id      = "ami-0b23bb3616e3892a6"
  instance_type = "t3.small"

  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = "${local.global_name_prefix}-asg-iam-role"
  iam_role_description        = "ECS role for ${local.global_name_prefix}-asg"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  security_groups = [module.security_group_for_ecs_node.security_group_id]
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"

  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-staging-execution-role-${var.env_suffix}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
