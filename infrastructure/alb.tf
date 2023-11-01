module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = format(module.naming.result, "alb")
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.security_group_for_alb.security_group_id]

  enable_deletion_protection = false

  target_groups = {
    grafana-monit = {
      name             = format(module.naming.result, "grafana-tg")
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/api/health"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      create_attachment = false
    }

    backend = {
      name             = format(module.naming.result, "backend-tg")
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/api/health"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      create_attachment = false
    }
  }

  listeners = {
    http-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn
      fixed_response = {
        content_type = "text/plain"
        status_code  = 403
        message_body = "invalid access"
      }
      rules = {
        grafana-rule = {
          priority = 1
          actions = [
            {
              type             = "forward"
              target_group_key = "grafana-monit"
            }
          ]
          conditions = [
            {
              host_header = {
                values = ["monit-${var.environment}.${var.domain_name}"]
              }
            }
          ]
        }
        backend-rule = {
          priority = 2
          actions = [
            {
              type             = "forward"
              target_group_key = "backend"
            }
          ]
          conditions = [
            {
              host_header = {
                values = ["${var.api_path_prefix}.${var.domain_name}"]
              }
            }
          ]
        }
      }
    }
  }
}
