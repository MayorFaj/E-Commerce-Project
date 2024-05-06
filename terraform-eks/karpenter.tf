data "aws_region" "current" {}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    annotations = {
      name = "karpenter"
    }
    name = "karpenter"
  }
}

# Configure the OIDC-backed identity provider to allow the Karpenter
# ServiceAccount to assume the role. This will actually create the role
# for us too.
module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.37.2"
  create_role                   = true
  role_name                     = "KarpenterNodeRole-${local.name}-cluster"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kubernetes_namespace.karpenter.id:karpenter"]
  allow_self_assume_role        = true

  depends_on = [
    module.eks,
    kubernetes_namespace.karpenter,
  ]

  tags = local.tags
}

resource "aws_iam_role_policy" "karpenter_contoller" {
  name = "KarpenterControllerPolicy"
  role = module.iam_assumable_role_karpenter.iam_role_name
  policy      = file("policies/KarpenterControllerPolicy.json")
}

###-------------------------------########################
data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  role       = module.iam_assumable_role_karpenter.iam_role_name
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}

data "aws_iam_policy" "eks_cni" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = module.iam_assumable_role_karpenter.iam_role_name
  policy_arn = data.aws_iam_policy.eks_cni.arn
}

data "aws_iam_policy" "eks_worker_node" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = module.iam_assumable_role_karpenter.iam_role_name
  policy_arn = data.aws_iam_policy.eks_worker_node.arn
}

data "aws_iam_policy" "ecr_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = module.iam_assumable_role_karpenter.iam_role_name
  policy_arn = data.aws_iam_policy.ecr_readonly.arn
}

resource "helm_release" "karpenter" {
  namespace = "${kubernetes_namespace.karpenter.id}"

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "0.35.4"

  values = [
    "${file("karpenter-values-file/values.yaml")}"
  ]

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_karpenter.iam_role_arn
  }

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  depends_on = [
    module.eks,
    kubernetes_namespace.karpenter,
  ]
}



data "kubectl_path_documents" "provisioner_manifests" {
  pattern = "karpenter-node-manifests/*.yaml"
  vars = {
    cluster_name = "${local.name}-cluster"
  }
}

resource "kubectl_manifest" "provisioners" {
  for_each  = data.kubectl_path_documents.provisioner_manifests.manifests
  yaml_body = each.value

  depends_on = [
    module.eks,
    kubernetes_namespace.karpenter,
    helm_release.karpenter
  ]
}

