resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.5.5"

  set {
    name  = "installCRDs"
    value = "true"
  }

  # run cert-manager chart on "system" nodes
  values = [
    <<VALUES
nodeSelector:
  hatchet.run/workload-kind: "system"
tolerations:
- key: "hatchet.run/workload-kind"
  operator: "Equal"
  value: "system"
  effect: "NoSchedule"
webhook:
  nodeSelector:
    hatchet.run/workload-kind: "system"
  tolerations:
  - key: "hatchet.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
cainjector:
  nodeSelector:
    hatchet.run/workload-kind: "system"
  tolerations:
  - key: "hatchet.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
VALUES
  ]
}
