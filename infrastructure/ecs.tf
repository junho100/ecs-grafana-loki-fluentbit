################################################################################
# Cluster
################################################################################

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"

  cluster_name = "${local.global_name_prefix}-ecs-cluster"

  default_capacity_provider_use_fargate = false

  cluster_settings = {
    name = "containerInsights"
    value = "disabled"
  }

  create_cloudwatch_log_group = false

  autoscaling_capacity_providers = {
    backend = {
      auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 2
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 90
      }
    }
  }
}

################################################################################
# Supporting Resources
################################################################################

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"

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
  max_size            = 2
  desired_capacity    = 2

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true
}
