resource "kubernetes_namespace" "kubecost" {
  metadata {
    annotations = {
      name = "kubecost"
    }
    name = "kubecost"
  }
}

resource "helm_release" "kubecost" {
  namespace = kubernetes_namespace.kubecost.id

  name       = "kubecost"
  repository = "oci://public.ecr.aws/kubecost"
  chart      = "cost-analyzer"
  version    = "2.2.0"

  values = [
    "${file("kubecost-values-file/values.yaml")}"
  ]


  depends_on = [
    module.eks,
    kubernetes_namespace.kubecost
  ]
}