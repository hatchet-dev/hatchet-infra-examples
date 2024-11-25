module "secret-manager" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  version    = "~> 0.1"
  project_id = var.gcp_project_id
  secrets = [
    {
      name                  = "${var.env_name}-database-certificate"
      automatic_replication = true
      secret_data           = google_sql_database_instance.default.server_ca_cert.0.cert
    },
  ]
}
