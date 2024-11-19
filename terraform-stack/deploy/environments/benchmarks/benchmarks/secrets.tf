

data "google_secret_manager_secret_version" "rabbitmq_password" {
  project = "hatchet-benchmarks"
  secret = "benchmarks-rabbitmq-password"
}

#
