module "vpc" {
  source = "../../../../modules/gcp/vpc"

  gcp_project_id = var.project
  env_name       = "hatchet"
  gcp_region     = var.region
}

module "gke" {
  source = "../../../../modules/gcp/gke"

  gcp_project_id =  var.project
  env_name       = "hatchet"
  gcp_region     = var.region
  vpc_name       = module.vpc.vpc_name
  subnet_name    = module.vpc.subnet_name
}

module "cloudsql-shared" {
  depends_on = [ module.vpc ]
  source = "../../../../modules/gcp/cloudsql-shared"

  gcp_project_id = var.project
  gcp_region     = var.region
  vpc_name       = module.vpc.vpc_name
}

module "cloudsql" {
  depends_on = [ module.vpc,module.cloudsql-shared, resource.google_secret_manager_secret.db_password ]

  source = "../../../../modules/gcp/cloudsql"

  gcp_project_id =  var.project
  env_name       = "hatchet"
  gcp_region     = var.region
  instance_name = "hatchet-private-postgres"
  max_connections = var.database_max_connections
  
  vpc_id       =  module.vpc.id

  database_name                = "hatchet"
  database_instance_type       = var.database_instance_type
  database_deletion_protection = true
  
  

}

module "cloudsql-iam" {
  source = "../../../../modules/gcp/cloudsql-iam"

  gcp_project_id =  var.project
  env_name       = "hatchet"
  instance = "hatchet-private-postgres"

  namespaces = [
    "hatchet",
  ]
}

resource "google_sql_database" "hatchet_database" {
  name     = "hatchet"
  instance = module.cloudsql.database_instance_name
}


  
resource "google_secret_manager_secret" "hatchet-database-ip-address" {
  secret_id = "hatchet-database-ip-address"
  replication {
    auto {} 
  }
}

resource "google_secret_manager_secret_version" "hatchet-database-ip-address" {
  secret      = google_secret_manager_secret.hatchet-database-ip-address.id
  secret_data = module.cloudsql.private_ip_address
}

# Create a regional static IP address
resource "google_compute_address" "hatchet-ip" {
  name         = "hatchet-ip"
  region       = var.region
  address_type = "EXTERNAL"
}

output "gke_static_ip" {
  value = google_compute_address.hatchet-ip.address
}


resource "google_secret_manager_secret" "db_password" {
  secret_id = "hatchet-database-password-auto"
  replication {
    auto {} 
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.password.result
}

resource "random_password" "password" {
  length           = 20
  special          = false
  override_special = "_%@"
}


resource "google_sql_user" "user" {
  name     = "hatchet"
  instance = google_sql_database.hatchet_database.instance
  password = google_secret_manager_secret_version.db_password_version.secret_data
}



resource "google_secret_manager_secret" "hatchet-rabbitmq-password" {
  secret_id = "hatchet-rabbitmq-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "hatchet-rabbitmq-password" {
  secret = google_secret_manager_secret.hatchet-rabbitmq-password.id
  secret_data = random_password.password.result  
}
