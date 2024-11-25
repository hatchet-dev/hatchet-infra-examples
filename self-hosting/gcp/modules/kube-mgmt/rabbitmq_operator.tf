resource "kubernetes_namespace" "rabbitmq_operator" {
  metadata {
    name = "rabbitmq-operator"
  }
}

resource "helm_release" "rabbitmq_operator" {
  name       = "rabbitmq-operator"
  namespace  = kubernetes_namespace.rabbitmq_operator.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq-cluster-operator"
  version    = "v3.11.2"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_pod_disruption_budget_v1" "production_ready_rabbitmq" {
  metadata {
    name = "production-ready-rabbitmq"
  }

  spec {
    max_unavailable = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "production-ready"
      }
    }
  }
}
