################################################################################
# Network
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = format(module.naming.result, "vpc")
  cidr = "10.1.0.0/16"

  azs = ["ap-northeast-2a", "ap-northeast-2c"]

  public_subnets   = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets  = ["10.1.3.0/24", "10.1.4.0/24"]
  database_subnets = ["10.1.5.0/24", "10.1.6.0/24"]

  public_subnet_names   = [format(module.naming.result, "public-subnet-1"), format(module.naming.result, "public-subnet-2")]
  private_subnet_names  = [format(module.naming.result, "backend-subnet-1"), format(module.naming.result, "backend-subnet-2")]
  database_subnet_names = [format(module.naming.result, "database-subnet-1"), format(module.naming.result, "database-subnet-2")]

  create_database_subnet_group = true

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}
