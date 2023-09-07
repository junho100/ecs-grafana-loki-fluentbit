################################################
# Security group
################################################

module "sg_for_bastion_host" {
  source  = "terraform-aws-modules/security-group/aws"

  name        = "${local.global_name_prefix}-bastion-host-sg"
  description = "sg for bastion host"
  vpc_id      = module.vpc.vgw_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "allow ssh from vpn ip address"
      cidr_blocks = var.vpn_ip_address
    },
  ]
}

module "sg_for_rds" {
  source  = "terraform-aws-modules/security-group/aws"

  name        = "${local.global_name_prefix}-rds-sg"
  description = "sg for rds instance"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
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
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "allow 3306 from vpn ip address"
      source_security_group_id = module.security_group_for_ecs_node.security_group_id
    }
  ]
}

module "security_group_for_ecs_node" {
  source  = "terraform-aws-modules/security-group/aws"

  name        = "${local.global_name_prefix}-ecs-node-sg"
  description = "sg for ecs nodes"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
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
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "allow 3306 from vpn ip address"
      source_security_group_id = module.security_group_for_ecs_node.security_group_id
    }
  ]
}