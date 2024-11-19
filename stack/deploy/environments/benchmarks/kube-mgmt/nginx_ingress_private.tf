resource "kubernetes_namespace" "nginx-ingress-private" {
  metadata {
    name = "nginx-ingress-private"
  }
}

resource "helm_release" "nginx_ingress_private" {
  name      = "nginx-ingress-private"
  chart     = "ingress-nginx"
  namespace = kubernetes_namespace.nginx-ingress-private.metadata[0].name
  version   = "4.7.0"

  repository = "https://kubernetes.github.io/ingress-nginx"

  values = [
    <<VALUES
controller:
  service:
    type: ClusterIP
  ingressClass: nginx-private
  ingressClassResource:
    name: nginx-private
    enabled: true
    default: false
    controllerValue: "k8s.io/nginx-private"
  nodeSelector:
    kubernetes.io/os: linux
    porter.run/workload-kind: "system"
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
  admissionWebhooks:
    patch:
      nodeSelector:
        porter.run/workload-kind: "system"
      tolerations:
      - key: "porter.run/workload-kind"
        operator: "Equal"
        value: "system"
        effect: "NoSchedule"
  config:
    compute-full-forwarded-for: 'true'
    enable-real-ip: 'true'
    enable-underscores-in-headers: 'true'
    proxy-read-timeout: '240'
    proxy-send-timeout: '240'
    use-forwarded-headers: 'true'
  metrics:
    annotations:
      prometheus.io/port: '10254'
      prometheus.io/scrape: 'true'
    enabled: true
  podAnnotations:
    prometheus.io/port: '10254'
    prometheus.io/scrape: 'true'
  replicaCount: 1
  resources:
    limits:
      memory: 270Mi
    requests:
      memory: 270Mi
      cpu: 250m
defaultBackend:
  nodeSelector:
    porter.run/workload-kind: "system"
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
VALUES
  ]
}

data "kubernetes_service" "nginx_ingress_private" {
  depends_on = [helm_release.nginx_ingress_private]

  metadata {
    name      = "nginx-ingress-private-ingress-nginx-controller"
    namespace = kubernetes_namespace.nginx-ingress-private.metadata[0].name
  }
}