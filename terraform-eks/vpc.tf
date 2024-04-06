module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs = local.azs

  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_subnet_ipv6_prefixes  = [0, 1, 2]
  private_subnet_ipv6_prefixes = [3, 4, 5]

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/${local.name}-cluster" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"              = 1
    "kubernetes.io/cluster/${local.name}-cluster"  = "owned"
    "karpenter.sh/discovery" = "${local.name}-cluster"
  }

  tags = local.tags
}