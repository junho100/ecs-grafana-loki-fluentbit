module "ecs_grafana_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name                     = "test-grafana-service-1231231"
  cluster_arn              = module.ecs_cluster.arn
  requires_compatibilities = ["EC2"]
  tasks_iam_role_arn       = module.ecs_task_role.iam_role_arn
  task_exec_iam_role_arn   = module.ecs_task_execution_role.iam_role_arn
  launch_type              = "EC2"
  network_mode             = "bridge"
  capacity_provider_strategy = {
    monitering = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["monitering"].name
      base              = 0
      weight            = 1
    }
  }
  cpu                   = 512
  memory                = 512
  subnet_ids            = module.vpc.private_subnets
  create_security_group = false

  container_definitions = {
    grafana-11 = {
      privileged               = true
      image                    = var.grafana_docker_image_url
      readonly_root_filesystem = false
      port_mappings = [
        {
          name          = "ecs-sample"
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      essential = true
      environment = [
        {
          name  = "GF_AUTH_ANONYMOUS_ORG_ROLE"
          value = "Admin"
        },
        {
          name  = "GF_AUTH_ANONYMOUS_ENABLED"
          value = "true"
        }
      ]
    }
  }

  load_balancer = {
    service = {
      target_group_arn = element(module.alb.target_group_arns, 0)
      container_name   = "grafana-11"
      container_port   = 3000
    }
  }

  service_connect_configuration = {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.ecs_cluster_namespace.arn
  }

  depends_on = [module.ecs_loki_service]
}

module "ecs_loki_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name                     = "test-loki-service"
  cluster_arn              = module.ecs_cluster.arn
  requires_compatibilities = ["EC2"]
  tasks_iam_role_arn       = module.ecs_task_role.iam_role_arn
  task_exec_iam_role_arn   = module.ecs_task_execution_role.iam_role_arn
  launch_type              = "EC2"
  network_mode             = "bridge"
  capacity_provider_strategy = {
    monitering = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["monitering"].name
      base              = 0
      weight            = 1
    }
  }
  cpu                   = 512
  memory                = 512
  subnet_ids            = module.vpc.private_subnets
  create_security_group = false
  wait_for_steady_state = true

  container_definitions = {
    loki = {
      privileged               = true
      image                    = var.loki_docker_image_url
      readonly_root_filesystem = false
      port_mappings = [
        {
          name          = "loki-3100"
          containerPort = 3100
          hostPort      = 3100
          protocol      = "tcp"
          appProtocol   = "http"
        },
        {
          name          = "loki-7946"
          containerPort = 7946
          hostPort      = 0
          protocol      = "tcp"
          appProtocol   = "http"
        },
        {
          name          = "loki-9095"
          containerPort = 9095
          hostPort      = 0
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      essential = true
      environment = [
        {
          name  = "LOKI_S3_ACCESS_KEY"
          value = "${urlencode("${aws_iam_access_key.iam_user_access_key.id}")}"
        },
        {
          name  = "LOKI_S3_SECRET_KEY"
          value = "${urlencode("${aws_iam_access_key.iam_user_access_key.secret}")}"
        },
        {
          name  = "S3_BUCKET_NAME"
          value = "${module.s3_bucket.s3_bucket_id}"
        }
      ]
    }
  }

  service_connect_configuration = {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.ecs_cluster_namespace.arn
    service = {
      client_alias = {
        dns_name = "loki"
        port     = 3100
      }
      port_name = "loki-3100"
    }
  }
}

module "ecs_backend_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name                     = "test-backend-service"
  cluster_arn              = module.ecs_cluster.arn
  requires_compatibilities = ["EC2"]
  tasks_iam_role_arn       = module.ecs_task_role.iam_role_arn
  task_exec_iam_role_arn   = module.ecs_task_execution_role.iam_role_arn
  launch_type              = "EC2"
  network_mode             = "bridge"
  capacity_provider_strategy = {
    monitering = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["backend"].name
      base              = 0
      weight            = 1
    }
  }
  cpu                   = 512
  memory                = 512
  subnet_ids            = module.vpc.private_subnets
  create_security_group = false

  container_definitions = {
    backend = {
      privileged               = true
      readonly_root_filesystem = false
      essential                = true
      image                    = "alpine:3.13"
      entrypoint               = ["sh", "-c"]
      command                  = ["/bin/sh -c \"while true; do sleep 15 ;echo hello_world; done\""]
      log_configuration = {
        logDriver = "awsfirelens"
        options = {
          Name        = "loki"
          host        = "loki"
          port        = "3100"
          labels      = "job=firelens"
          line_format = "key_value"
        }
      }
    }
    fluentbit = {
      privileged               = true
      image                    = "public.ecr.aws/aws-observability/aws-for-fluent-bit:latest"
      readonly_root_filesystem = false
      firelens_configuration = {
        type = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
        }
      }
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/firelens-container/"
          awslogs-region        = "ap-northeast-2"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "firelens"
        }
      }
      essential = true
    }
  }

  service_connect_configuration = {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.ecs_cluster_namespace.arn
  }

  depends_on = [module.ecs_loki_service]
}
