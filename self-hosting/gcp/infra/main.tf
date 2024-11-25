module "gcp_services" {
  # Note: change this to a module registry or remote file URL. 
  source = "../modules/services"

  gcp_project_id = var.project
}

module "vpc" {
  depends_on = [module.gcp_services]
  source     = "../modules/vpc"

  gcp_project_id = var.project
  env_name       = var.env_name
  gcp_region     = var.region
}

module "gke" {
  source = "../modules/gke"

  gcp_project_id = var.project
  env_name       = var.env_name
  gcp_region     = var.region
  vpc_name       = module.vpc.vpc_name
  subnet_name    = module.vpc.subnet_name
}

module "cloudsql-shared" {
  depends_on = [module.vpc]
  source     = "../modules/cloudsql-network"

  gcp_project_id = var.project
  gcp_region     = var.region
  vpc_name       = module.vpc.vpc_name
}

module "cloudsql" {
  depends_on = [module.vpc, module.cloudsql-shared, resource.google_secret_manager_secret.db_password]

  source = "../modules/cloudsql"

  gcp_project_id  = var.project
  env_name        = var.env_name
  gcp_region      = var.region
  instance_name   = "${var.env_name}-private-postgres"
  max_connections = var.database_max_connections

  vpc_id = module.vpc.id

  database_name                = "hatchet"
  database_instance_type       = var.database_instance_type
  database_deletion_protection = false
}

module "cloudsql-iam" {
  depends_on = [module.cloudsql]
  source     = "../modules/cloudsql-iam"

  gcp_project_id = var.project
  env_name       = var.env_name
  instance       = "hatchet-private-postgres"

  namespaces = [
    "hatchet",
  ]
}

resource "google_sql_database" "hatchet_database" {
  name     = "hatchet"
  instance = module.cloudsql.database_instance_name
}

resource "google_secret_manager_secret" "hatchet-database-ip-address" {
  depends_on = [module.gcp_services]
  secret_id  = "hatchet-database-ip-address"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "hatchet-database-ip-address" {
  depends_on = [module.gcp_services]

  secret      = google_secret_manager_secret.hatchet-database-ip-address.id
  secret_data = module.cloudsql.private_ip_address
}

resource "google_secret_manager_secret" "db_password" {
  depends_on = [module.gcp_services]

  secret_id = "hatchet-database-password-auto"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  depends_on = [module.gcp_services]

  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.password.result
}

resource "random_password" "password" {
  length           = 20
  special          = false
  override_special = "_%@"
}

resource "google_sql_user" "user" {
  depends_on = [google_sql_database.hatchet_database]
  name       = "hatchet"
  instance   = google_sql_database.hatchet_database.instance
  password   = google_secret_manager_secret_version.db_password_version.secret_data
}

resource "google_secret_manager_secret" "hatchet-rabbitmq-password" {
  depends_on = [module.gcp_services]

  secret_id = "hatchet-rabbitmq-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "hatchet-rabbitmq-password" {
  depends_on = [module.gcp_services]

  secret      = google_secret_manager_secret.hatchet-rabbitmq-password.id
  secret_data = random_password.password.result
}

# provision an IP address for NGINX along with the engine
resource "google_compute_address" "nginx_lb" {
  name   = "${var.env_name}-nginx"
  region = var.region
}

resource "google_compute_address" "engine_lb" {
  name   = "${var.env_name}-engine"
  region = var.region
}

output "api_ip_address" {
  value = google_compute_address.nginx_lb.address
}

output "engine_ip_address" {
  value = google_compute_address.engine_lb.address
}
