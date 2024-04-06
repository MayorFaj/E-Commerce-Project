locals {
  name            = "rias-touch"
  cluster_version = "1.29"
  region          = "eu-central-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  developer_usernames = "developer"

  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = module.eks_admins_iam_role.iam_role_name
      groups   = ["system:masters"] 
    },
    # {
    #   rolearn  = module.iam_assumable_role_karpenter.iam_role_arn
    #   username = "system:node:{{EC2PrivateDNSName}}"
    #   groups   = ["system:nodes","system:bootstrappers"]
    # }
  ]

  aws_auth_users = "developer"

  aws_auth_accounts = [
    tostring(data.aws_caller_identity.current.account_id)
  ]

  ebs_csi_service_account_namespace = "kube-system"
  ebs_csi_service_account_name      = "ebs-csi-controller-sa"

  tags = {
    Environment                                   = "dev"
    "kubernetes.io/cluster/${local.name}-cluster" = "owned"
    GithubRepo                                    = "terraform-aws-eks"
    GithubOrg                                     = "terraform-aws-modules"
  }
}

