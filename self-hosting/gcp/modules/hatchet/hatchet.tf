resource "kubernetes_namespace" "hatchet" {
  metadata {
    name = "hatchet"
  }
}

data "google_secret_manager_secret_version" "rabbitmq_password" {
  project = var.project
  secret  = "hatchet-rabbitmq-password"
}

data "google_secret_manager_secret" "db_password" {
  secret_id = "hatchet-database-password-auto"
}

data "google_secret_manager_secret_version" "db_password" {
  secret  = data.google_secret_manager_secret.db_password.id
  version = "latest"
}

data "google_secret_manager_secret" "database_ip_address" {
  secret_id = "hatchet-database-ip-address"
}

data "google_secret_manager_secret_version" "database_ip_address" {
  secret  = data.google_secret_manager_secret.database_ip_address.id
  version = "latest"
}

resource "kubernetes_secret" "config" {
  metadata {
    name      = "hatchet-additional-config"
    namespace = kubernetes_namespace.hatchet.metadata[0].name
  }

  data = {
    "SERVER_URL"                    = "https://${var.hatchet_server_url}"
    "SERVER_AUTH_COOKIE_DOMAIN"     = "${var.hatchet_server_url}"
    "SERVER_GRPC_INSECURE"          = "false"
    "SERVER_GRPC_BIND_ADDRESS"      = "0.0.0.0"
    "SERVER_GRPC_BROADCAST_ADDRESS" = "${var.hatchet_engine_url}"
  }
}

resource "kubernetes_secret" "database_creds" {
  metadata {
    name      = "database-creds"
    namespace = kubernetes_namespace.hatchet.metadata[0].name
  }

  data = {
    "DATABASE_URL"                  = "postgresql://hatchet:${data.google_secret_manager_secret_version.db_password.secret_data}@${data.google_secret_manager_secret_version.database_ip_address.secret_data}:5432/hatchet"
    "DATABASE_POSTGRES_HOST"        = data.google_secret_manager_secret_version.database_ip_address.secret_data
    "DATABASE_POSTGRES_PORT"        = "5432"
    "DATABASE_POSTGRES_USERNAME"    = "hatchet"
    "DATABASE_POSTGRES_PASSWORD"    = data.google_secret_manager_secret_version.db_password.secret_data
    "DATABASE_POSTGRES_DB_NAME"     = "hatchet"
    "DATABASE_POSTGRES_SSL_MODE"    = "disable"
    "SERVER_TASKQUEUE_RABBITMQ_URL" = "amqp://rabbitmq:${data.google_secret_manager_secret_version.rabbitmq_password.secret_data}@rabbitmq:5672/"
  }
}

resource "kubernetes_secret" "rabbitmq_certs" {
  metadata {
    name      = "rabbitmq-certs"
    namespace = kubernetes_namespace.hatchet.metadata[0].name
  }

  data = {
    "default_user.conf" = <<CONF
default_user = rabbitmq
default_pass = ${data.google_secret_manager_secret_version.rabbitmq_password.secret_data}
  CONF
    host                = "vault-default-user.default.svc"
    password            = data.google_secret_manager_secret_version.rabbitmq_password.secret_data
    port                = "5672"
    provider : "rabbitmq"
    type : "rabbitmq"
    username : "rabbitmq"
  }
}

data "google_compute_address" "nginx_lb" {
  name   = "${var.env_name}-nginx"
  region = var.region
}

data "google_compute_address" "engine_lb" {
  name   = "${var.env_name}-engine"
  region = var.region
}

resource "kubernetes_manifest" "grpc_engine_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "grpc-engine-certificate"
      "namespace" = kubernetes_namespace.hatchet.metadata[0].name
    }
    "spec" = {
      "secretName" = "engine-certificate"
      "dnsNames" = [
        var.hatchet_engine_url
      ]
      "issuerRef" = {
        "name" = "letsencrypt-cloudflare-dns"
        "kind" = "ClusterIssuer"
      }
    }
  }
}

resource "kubernetes_pod_disruption_budget_v1" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.hatchet.metadata[0].name
  }

  spec {
    max_unavailable = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "rabbitmq"
      }
    }
  }
}

resource "kubernetes_manifest" "rabbitmq_cluster" {
  manifest = {
    "apiVersion" = "rabbitmq.com/v1beta1"
    "kind"       = "RabbitmqCluster"
    "metadata" = {
      "name"      = "rabbitmq"
      "namespace" = kubernetes_namespace.hatchet.metadata[0].name
    }
    "spec" = {
      "replicas" = 3
      "resources" = {
        "requests" = {
          "cpu"    = "1"
          "memory" = "2Gi"
        }
        "limits" = {
          "cpu"    = "1"
          "memory" = "2Gi"
        }
      }
      "rabbitmq" = {
        "additionalConfig" = <<-EOT
          cluster_partition_handling = pause_minority
          disk_free_limit.relative = 1.0
          collect_statistics_interval = 10000
        EOT
      }
      "persistence" = {
        "storageClassName" = "ssd"
        "storage"          = "100Gi"
      }
      "affinity" = {
        "podAntiAffinity" = {
          "requiredDuringSchedulingIgnoredDuringExecution" = [
            {
              "labelSelector" = {
                "matchExpressions" = [
                  {
                    "key"      = "app.kubernetes.io/name"
                    "operator" = "In"
                    "values"   = ["rabbitmq"]
                  }
                ]
              }
              "topologyKey" = "kubernetes.io/hostname"
            }
          ]
        }
      }
      "override" = {
        "statefulSet" = {
          "spec" = {
            "template" = {
              "spec" = {
                "containers" = []
                "topologySpreadConstraints" = [
                  {
                    "maxSkew"           = 1
                    "topologyKey"       = "topology.kubernetes.io/zone"
                    "whenUnsatisfiable" = "DoNotSchedule"
                    "labelSelector" = {
                      "matchLabels" = {
                        "app.kubernetes.io/name" = "rabbitmq"
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
      "secretBackend" = {
        "externalSecret" = {
          "name" = "${kubernetes_secret.rabbitmq_certs.metadata[0].name}"
        }
      }
    }
  }
}

resource "helm_release" "hatchet_stack" {
  depends_on    = [kubernetes_manifest.grpc_engine_certificate]
  name          = "hatchet-ha"
  chart         = "hatchet-ha"
  repository    = "https://hatchet-dev.github.io/hatchet-charts"
  namespace     = kubernetes_namespace.hatchet.metadata[0].name
  version       = "0.8.0"
  recreate_pods = true

  values = [
    <<EOF
sharedEnvEnabled: false
frontend:
  ingress:
    enabled: true
    ingressClassName: nginx
    labels: {}
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: 50m
      nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
      nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
      nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
      cert-manager.io/cluster-issuer: letsencrypt-cloudflare-dns
    hosts:
    - host: ${var.hatchet_server_url}
      paths:
      - path: /api
        backend:
          serviceName: hatchet-ha-api
          servicePort: 8080
      - path: /
        backend:
          serviceName: hatchet-ha-frontend
          servicePort: 8080
    tls:
    - secretName: hatchet-api
      hosts:
      - ${var.hatchet_server_url}
api:
  seedJob:
    enabled: false
  envFrom:
    - secretRef:
        name: ${kubernetes_secret.database_creds.metadata[0].name}
    - secretRef:
        name: ${kubernetes_secret.config.metadata[0].name}
grpc:
  replicaCount: 2
  env:
    SERVER_TLS_CERT_FILE: "/etc/tls/tls.crt"
    SERVER_TLS_KEY_FILE: "/etc/tls/tls.key"
    DATABASE_MAX_CONNS: "150"
  envFrom:
    - secretRef:
        name: ${kubernetes_secret.database_creds.metadata[0].name}
    - secretRef:
        name: ${kubernetes_secret.config.metadata[0].name}
  extraVolumeMounts:
    - name: engine-certificate
      mountPath: "/etc/tls"
      readOnly: true
  extraVolumes:
    - name: engine-certificate
      secret:
        secretName: engine-certificate   
  service:
    type: LoadBalancer
    externalPort: 443
    internalPort: 7070
    loadBalancerIP: ${data.google_compute_address.engine_lb.address}
    annotations:
      cloud.google.com/backend-config: '{"default": "websockets-backendconfig"}' 
scheduler:
  replicaCount: 1
  env: 
    DATABASE_MAX_CONNS: "150"
  envFrom:
    - secretRef:
        name: ${kubernetes_secret.database_creds.metadata[0].name}
    - secretRef:
        name: ${kubernetes_secret.config.metadata[0].name}
controllers:
  replicaCount: 2
  env: 
    DATABASE_MAX_CONNS: "150"
  envFrom:
    - secretRef:
        name: ${kubernetes_secret.database_creds.metadata[0].name}
    - secretRef:
        name: ${kubernetes_secret.config.metadata[0].name}
postgres:
  enabled: false
rabbitmq:
  enabled: false
EOF
  ]
}

