# Create a service account for CloudSQL IAM proxy to use to connect to the database.
module "cloudsql_proxy_service_account" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 3.0"

  project_id   = var.gcp_project_id
  display_name = "${var.env_name} cloudsql proxy user"
  names = [
    "${var.env_name}-cloudsql-proxy"
  ]
  description   = "Service account used by CloudSQL IAM proxy as a database user."
  generate_keys = false

  project_roles = [
    "${var.gcp_project_id}=>roles/cloudsql.client",
  ]
}

locals {
  api_members    = [for namespace in var.namespaces : "serviceAccount:${var.gcp_project_id}.svc.id.goog[${namespace}/hatchet-api]"]
  engine_members = [for namespace in var.namespaces : "serviceAccount:${var.gcp_project_id}.svc.id.goog[${namespace}/hatchet-engine]"]

  members = concat(
    local.api_members,
    local.engine_members,
    ["serviceAccount:${var.gcp_project_id}.svc.id.goog[metabase/metabase]"]
  )
}

resource "random_password" "password" {
  length           = 20
  special          = true
  override_special = "_%@"
}

resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "${var.env_name}-database-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = random_password.password.result
}
