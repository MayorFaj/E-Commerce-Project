# ################################################################################
# # Cluster Data
# ################################################################################

##--------  Endpoint for your Kubernetes API server
output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

##--------- The name of the EKS cluster
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

##--------- Base64 encoded certificate data required to communicate with the cluster
output "eks_cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}


## The URL on the EKS cluster for the OpenID Connect identity provider
output "eks_cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

##------- The OpenID Connect identity provider (issuer URL without leading `https://`)
output "eks_oidc_provider" {
  value = module.eks.oidc_provider
}

##------- The ARN of the OIDC Provider if `enable_irsa = true
output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "kms_key_id" {
  value = module.ebs_kms_key.key_arn
}

# output "karpenter_iam_role_arn" {
#   value = module.iam_assumable_role_karpenter.iam_role_arn
# }

###--------- NAMESPACES
# output "argo_namespace_name" {
#   value = kubernetes_namespace.argo["argocd"].metadata[0].name
# }