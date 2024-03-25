module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>19.0"

  cluster_name    = "${local.name}-cluster"
  cluster_version = local.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id = module.vpc.vpc_id

  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets
  create_kms_key           = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.ebs_kms_key.key_arn
  }

  #cluster_ip_family = "ipv6"

  #create_cni_ipv6_iam_policy = true

  manage_aws_auth_configmap = true

  aws_auth_roles = local.aws_auth_roles

  aws_auth_accounts = local.aws_auth_accounts

  #enable_irsa = true

  iam_role_additional_policies = {
    additional                      = aws_iam_policy.additional.arn
    EKSNodegroupClusterIssuerPolicy = aws_iam_policy.eks_nodegroup_cluster_issuer_policy.arn
    EKSNodegroupExternalDNSPolicy   = aws_iam_policy.eks_nodegroup_exteral_dns_policy.arn
    EKSNodegroupECRFullAccess       = aws_iam_policy.eks_nodegroup_ecr_full_access.arn
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }

    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
      most_recent              = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }
    #before_compute           = true
    #service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    # configuration_values = jsonencode({
    #   env = {
    #     # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
    #     ENABLE_PREFIX_DELEGATION = "true"
    #     WARM_PREFIX_TARGET       = "1"
    #   }
    # })
    #}
  }

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    ingress_cluster_tcp = {
      description = "Allow Access to Security group from anywhere."
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = aws_security_group.remote_access.id
    }
  }



  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = aws_security_group.remote_access.id
    }

    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_groups = {
    general = {
      desired_size         = 2
      min_size             = 1
      max_size             = 5
      force_update_version = true

      iam_role_additional_policies = {
        additional                      = aws_iam_policy.additional.arn
        EKSNodegroupClusterIssuerPolicy = aws_iam_policy.eks_nodegroup_cluster_issuer_policy.arn
        EKSNodegroupExternalDNSPolicy   = aws_iam_policy.eks_nodegroup_exteral_dns_policy.arn
        EKSNodegroupECRFullAccess       = aws_iam_policy.eks_nodegroup_ecr_full_access.arn
      }

      labels = {
        role       = "spot"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 50
            volume_type = "gp3"
            #iops                  = 3000
            #throughput            = 150
            encrypted             = true
            kms_key_id            = module.ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
      }

    }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 5

      labels = {
        role       = "spot"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      taints = [{
        key    = "dedicated"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]

      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
    }

  }
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.name}-cluster" = null
  }

  tags = local.tags
}
