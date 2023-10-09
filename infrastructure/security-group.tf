################################################
# Security group
################################################

module "sg_for_bastion_host" {
  source = "terraform-aws-modules/security-group/aws"

  name        = format(module.naming.result, "bastion-host-sg")
  description = "sg for bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "allow temp all"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "allow ssh from vpn ip address"
      cidr_blocks = var.vpn_ip_address
    },
  ]

  egress_rules = ["all-all"]
}

module "sg_for_rds" {
  source = "terraform-aws-modules/security-group/aws"

  name        = format(module.naming.result, "rds-sg")
  description = "sg for rds instance"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "allow temp all"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "allow 3306 from vpn ip address"
      cidr_blocks = var.vpn_ip_address
    },
  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "allow 3306 from vpn ip address"
      source_security_group_id = module.security_group_for_ecs_node.security_group_id
    }
  ]

  egress_rules = ["all-all"]
}

module "security_group_for_ecs_node" {
  source = "terraform-aws-modules/security-group/aws"

  name        = format(module.naming.result, "ecs-node-sg")
  description = "sg for ecs nodes"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "allow temp all"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "allow 3306 from vpn ip address"
      cidr_blocks = var.vpn_ip_address
    },
  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "allow 3306 from vpn ip address"
      source_security_group_id = module.security_group_for_ecs_node.security_group_id
    }
  ]

  egress_rules = ["all-all"]
}

module "security_group_for_alb" {
  source = "terraform-aws-modules/security-group/aws"

  name        = format(module.naming.result, "alb-sg")
  description = "sg for alb"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "allow temp all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]
}
