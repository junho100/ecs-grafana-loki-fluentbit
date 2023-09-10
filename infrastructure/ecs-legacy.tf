# ################################################################################
# # Cluster
# ################################################################################

# module "ecs" {
#   source  = "terraform-aws-modules/ecs/aws"

#   cluster_name = "${local.global_name_prefix}-ecs-cluster"

#   default_capacity_provider_use_fargate = false

#   cluster_settings = {
#     name = "containerInsights"
#     value = "disabled"
#   }

#   create_cloudwatch_log_group = false

#   autoscaling_capacity_providers = {
#     backend = {
#       auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
#       managed_termination_protection = "ENABLED"

#       managed_scaling = {
#         maximum_scaling_step_size = 1
#         minimum_scaling_step_size = 1
#         status                    = "ENABLED"
#         target_capacity           = 90
#       }
#     }
#   }

#   services = {
#     backend = {
#       launch_type = "EC2"
#       # service_connect_configuration = 
#       create_task_definition = true
#       container_definitions = {
#         app = {
#           command = ["/bin/sh -c \"while true; do sleep 15 ;echo hello_world; done\""]
#           entrypoint = ["sh", "-c"]
#           essential = true
#           image = "alpine:3.13"
#           log_configuration = {
#             logDriver = "awsfirelens"
#             options = {
#               Name = "loki"
#               Host = "http://loki:3100"
#               labels = "{job=\"firelens\"}"
#               LabelKeys = "container_name,ecs_task_definition,source,ecs_cluster"
#               RemoveKeys = "container_id,ecs_task_arn"
#               LineFormat = "key_value"
#               URL = "http://loki:3100/loki/api/v1/push"
#             }
#           }
#         }

#         fluent-bit = {
#           essential = true
#           image = "grafana/fluent-bit-plugin-loki:1.5.0-amd64"
#           firelens_configuration = {
#             type = "fluentbit"
#             options = {
#               enable-ecs-log-metadata = "true"
#             }
#           }
#           # log_configuration = {
#           #   logDriver = "awslogs"
#           #   options = {
#           #     Name = "loki"
#           #     Host = "http://loki:3100"
#           #     labels = "{job=\"firelens\"}"
#           #     LabelKeys = "container_name,ecs_task_definition,source,ecs_cluster"
#           #     RemoveKeys = "container_id,ecs_task_arn"
#           #     LineFormat = "key_value"
#           #     URL = "http://loki:3100/loki/api/v1/push"
#           #   }
#           # }
#         }
#       }
#       cpu = 512
#       memory = 512
#       network_mode = "awsvpc"
#       requires_compatibilities = ["EC2"]
#       create_task_exec_iam_role = false
#       create_tasks_iam_role = false
#       create_security_group = false
#     }

#     loki = {
#       launch_type = "EC2"
#       # service_connect_configuration = 
#       create_security_group = false
#     }

#     grafana = {
#       launch_type = "EC2"
#       assign_public_ip = true
#       essential = true
#       # service_connect_configuration = 
#       create_security_group = false
#       image = "grafana/grafana:latest"
#       cpu = 0
#       network_mode = "bridge"
#       port_mappings = [
#         {
#           name          = "grafana"
#           containerPort = 3000
#           hostPort = 3000
#           protocol      = "tcp"
#         }
#       ]
#       environment = [{
#         name = "GF_AUTH_ANONYMOUS_ORG_ROLE"
#         value = "Admin"
#       }, {
#         name = "GF_AUTH_ANONYMOUS_ENABLED",
#         value = "true"
#       }]
#     }
#   }
# }

# ################################################################################
# # Supporting Resources
# ################################################################################

# module "autoscaling" {
#   source  = "terraform-aws-modules/autoscaling/aws"

#   name = "${local.global_name_prefix}-asg"

#   image_id      = "ami-0b23bb3616e3892a6"
#   instance_type = "t3.small"

#   ignore_desired_capacity_changes = true

#   create_iam_instance_profile = true
#   iam_role_name               = "${local.global_name_prefix}-asg-iam-role"
#   iam_role_description        = "ECS role for ${local.global_name_prefix}-asg"
#   iam_role_policies = {
#     AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
#     AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   }

#   vpc_zone_identifier = module.vpc.private_subnets
#   health_check_type   = "EC2"
#   min_size            = 1
#   max_size            = 1
#   desired_capacity    = 1

#   autoscaling_group_tags = {
#     AmazonECSManaged = true
#   }

#   # Required for  managed_termination_protection = "ENABLED"
#   protect_from_scale_in = true

#   security_groups = [module.security_group_for_ecs_node.security_group_id]
# }

# resource "aws_service_discovery_http_namespace" "this" {
#   name        = "${local.global_name_prefix}-ecs-cluster"
#   description = "CloudMap namespace for ${local.global_name_prefix}-ecs-cluster"
# }