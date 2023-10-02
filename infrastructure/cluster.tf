module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = "test"

  default_capacity_provider_use_fargate = false

  cluster_settings = {
    name  = "containerInsights"
    value = "disabled"
  }

  autoscaling_capacity_providers = {
    monitering = {
      auto_scaling_group_arn         = module.monitering_autoscaling.autoscaling_group_arn
      managed_termination_protection = "ENABLED"
      default_capacity_provider_strategy = {
        base   = 0
        weight = 1
      }
    }

    backend = {
      auto_scaling_group_arn         = module.backend_autoscaling.autoscaling_group_arn
      managed_termination_protection = "ENABLED"
      default_capacity_provider_strategy = {
        base   = 0
        weight = 1
      }
    }
  }
}
