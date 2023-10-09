module "monitering_autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = format(module.naming.result, "monitering-asg")

  image_id      = "ami-0f38a3ea566a01eb4"
  instance_type = "t3.small"

  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = format(module.naming.result, "moni-asg-role")
  iam_role_description        = "ECS role for monitering auto scaling group"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    S3                                  = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  user_data = base64encode("#!/bin/bash\necho ECS_CLUSTER=${format(module.naming.result, "ecs-cluster")} >> /etc/ecs/ecs.config;")

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  security_groups = [module.security_group_for_ecs_node.security_group_id]

  target_group_arns = module.alb.target_group_arns
}

module "backend_autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = format(module.naming.result, "backend-asg")

  image_id      = "ami-0f38a3ea566a01eb4"
  instance_type = "t3.small"

  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = format(module.naming.result, "bknd-asg-role")
  iam_role_description        = "ECS role for backend auto scaling group"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    S3                                  = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  user_data = base64encode("#!/bin/bash\necho ECS_CLUSTER=test >> /etc/ecs/ecs.config;")

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  security_groups = [module.security_group_for_ecs_node.security_group_id]

  target_group_arns = module.alb.target_group_arns
}
