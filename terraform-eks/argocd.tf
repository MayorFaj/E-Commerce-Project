resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      name = "argocd"
    }
    name = "argocd"
  }
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
    kubernetes_namespace.argocd
  ]
}