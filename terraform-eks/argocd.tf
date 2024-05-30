resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      name = "argocd"
    }
    name = "argocd"
  }
}

data "kubectl_path_documents" "config_manifests" {
  pattern = "argocd-values-file/config.yaml"
}

resource "kubectl_manifest" "argocd_manifests" {
  for_each  = data.kubectl_path_documents.config_manifests.manifests
  yaml_body = each.value

  depends_on = [
    module.eks,
    kubernetes_namespace.argocd
  ]
}

resource "helm_release" "argocd" {
  namespace = kubernetes_namespace.argocd.id

  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.3.1"

  values = [
    "${file("argocd-values-file/values.yaml")}"
  ]


  depends_on = [
    module.eks,
    kubernetes_namespace.argocd,
    kubectl_manifest.argocd_manifests
  ]
}
