resource "kubernetes_namespace" "hatchet" {
  metadata {
    name = "hatchet"
  }
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

resource "kubernetes_secret" "database_creds" {
  metadata {
    name      = "database-creds"
    namespace = kubernetes_namespace.hatchet.metadata[0].name
  }

  data = {
    "DATABASE_URL" =  "postgresql://hatchet:${data.google_secret_manager_secret_version.db_password.secret_data}@${data.google_secret_manager_secret_version.database_ip_address.secret_data}:5432/hatchet"
    "DATABASE_POSTGRES_HOST" = data.google_secret_manager_secret_version.database_ip_address.secret_data
    "DATABASE_POSTGRES_PORT" = "5432"
    "DATABASE_POSTGRES_USERNAME" = "hatchet"
    "DATABASE_POSTGRES_PASSWORD" = data.google_secret_manager_secret_version.db_password.secret_data
    "DATABASE_POSTGRES_DB_NAME" = "hatchet"
    "DATABASE_POSTGRES_SSL_MODE" = "disable"
    "SERVER_TASKQUEUE_RABBITMQ_URL" = "amqp://rabbitmq:${data.google_secret_manager_secret_version.rabbitmq_password.secret_data}@rabbitmq:5672/"
  }
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "server-auth-cookie-secrets"
    namespace = kubernetes_namespace.hatchet.metadata[0].name
  }

  data = {
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
  host = "vault-default-user.default.svc"
  password = data.google_secret_manager_secret_version.rabbitmq_password.secret_data
  port = "5672"
  provider: "rabbitmq"
  type: "rabbitmq"
  username: "rabbitmq"
  }
}
resource "helm_release" "hatchet_stack" {
  name      = "hatchet-stack"
  chart     = "../../../../charts/hatchet-stack"
  namespace = kubernetes_namespace.hatchet.metadata[0].name
  version   = "0.0.4"
  recreate_pods = true


  values = [
    <<-EOF
    caddy:
      enabled: true
    # an example worker
    workers:
      replicaCount: 1           
    engine:
      setupJob:
        enabled: true
        env:
          DATABASE_POSTGRES_PASSWORD: ${kubernetes_secret.database_creds.data["DATABASE_POSTGRES_PASSWORD"]}
          DATABASE_URL: ${kubernetes_secret.database_creds.data["DATABASE_URL"]}
      env:
        DATABASE_POSTGRES_PASSWORD: ${kubernetes_secret.database_creds.data["DATABASE_POSTGRES_PASSWORD"]}
        DATABASE_URL: ${kubernetes_secret.database_creds.data["DATABASE_URL"]}
        DATABASE_POSTGRES_HOST: ${kubernetes_secret.database_creds.data["DATABASE_POSTGRES_HOST"]}        
        DATABASE_MAX_CONNS: "800"
      image:
        repository: "ghcr.io/hatchet-dev/hatchet/hatchet-engine"
        tag: "v0.51.2"
        pullPolicy: "Always"             
    api:
      image:
        repository: "ghcr.io/hatchet-dev/hatchet/hatchet-api"
        tag: "v0.51.2"
        pullPolicy: "Always"
      env:
        DATABASE_POSTGRES_PASSWORD: ${kubernetes_secret.database_creds.data["DATABASE_POSTGRES_PASSWORD"]}
        DATABASE_URL: ${kubernetes_secret.database_creds.data["DATABASE_URL"]}
        DATABASE_POSTGRES_HOST: ${kubernetes_secret.database_creds.data["DATABASE_POSTGRES_HOST"]}        
      envFrom:
        - secretRef:
            name: ${kubernetes_secret.database_creds.metadata[0].name}
    extraManifests:
    - apiVersion: rabbitmq.com/v1beta1
      kind: RabbitmqCluster
      metadata:
        name: rabbitmq
      spec:
        replicas: 1
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 800m
            memory: 1Gi
    EOF
  ]
}

