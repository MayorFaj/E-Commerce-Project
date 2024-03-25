module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs = local.azs

  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  #intra_subnets   = local.intra_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  #enable_ipv6            = true
  #create_egress_only_igw = true

  public_subnet_ipv6_prefixes = [0, 1, 2]
  #public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_ipv6_prefixes = [3, 4, 5]
  #private_subnet_assign_ipv6_address_on_creation = true
  #intra_subnet_ipv6_prefixes                     = [6, 7, 8]
  #intra_subnet_assign_ipv6_address_on_creation   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/${local.name}-cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = 1
    "kubernetes.io/cluster/${local.name}-cluster" = "shared"
  }

  tags = local.tags
}