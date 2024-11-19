

data "google_secret_manager_secret_version" "rabbitmq_password" {
  project = var.project
  secret = "hatchet-rabbitmq-password"
}

#
