resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "google_compute_address" "lb" {
  name   = "k8s-benchmarks-lb"
  region = "us-west1"
}

resource "helm_release" "nginx_ingress" {
  name      = "nginx-ingress"
  chart     = "ingress-nginx"
  namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  version   = "4.7.0"

  repository = "https://kubernetes.github.io/ingress-nginx"

  values = [
    <<VALUES
controller:
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
    allow-snippet-annotations: 'true'
  service:
    externalTrafficPolicy: Local
    loadBalancerIP: ${google_compute_address.lb.address}
    annotations:
      cloud.google.com/backend-config: '{"default": "websockets-backendconfig"}'
  metrics:
    annotations:
      prometheus.io/port: '10254'
      prometheus.io/scrape: 'true'
    enabled: true
  podAnnotations:
    prometheus.io/port: '10254'
    prometheus.io/scrape: 'true'
  replicaCount: 2
  resources:
    limits:
      memory: 270Mi
    requests:
      memory: 270Mi
      cpu: 250m
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: nginx-ingress
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: nginx-ingress
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 400
    targetMemoryUtilizationPercentage: 80
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

data "kubernetes_service" "nginx_ingress" {
  depends_on = [helm_release.nginx_ingress]

  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }
}