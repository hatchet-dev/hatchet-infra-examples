module "vpc" {
  source = "../../../../modules/gcp/vpc"

  gcp_project_id = "hatchet-benchmarks"
  env_name       = "benchmarks"
  gcp_region     = "us-west1"
}

module "gke" {
  source = "../../../../modules/gcp/gke"

  gcp_project_id = "hatchet-benchmarks"
  env_name       = "benchmarks"
  gcp_region     = "us-west1"
  vpc_name       = module.vpc.vpc_name
  subnet_name    = module.vpc.subnet_name
}

module "cloudsql-shared" {
  depends_on = [ module.vpc ]
  source = "../../../../modules/gcp/cloudsql-shared"

  gcp_project_id = "hatchet-benchmarks"
  gcp_region     = "us-west1"
  vpc_name       = module.vpc.vpc_name
}

module "cloudsql" {
  depends_on = [ module.vpc,module.cloudsql-shared, resource.google_secret_manager_secret.db_password ]

  source = "../../../../modules/gcp/cloudsql"

  gcp_project_id = "hatchet-benchmarks"
  env_name       = "benchmarks"
  gcp_region     = "us-west1"
  instance_name = "benchmarks-private-postgres"
  max_connections = 1000
  
  vpc_id       = "projects/hatchet-benchmarks/global/networks/benchmarks-internal-vpc"

  database_name                = "hatchet"
  database_instance_type       = "db-custom-16-15360"
  database_deletion_protection = true
  
  

}

module "cloudsql-iam" {
  source = "../../../../modules/gcp/cloudsql-iam"

  gcp_project_id = "hatchet-benchmarks"
  env_name       = "benchmarks"
  instance = "benchmarks-private-postgres"

  namespaces = [
    "benchmarks",
  ]
}

resource "google_sql_database" "benchmarks_database" {
  name     = "benchmarks"
  instance = module.cloudsql.database_instance_name
}


  
resource "google_secret_manager_secret" "benchmarks-database-ip-address" {
  secret_id = "benchmarks-database-ip-address"
  replication {
    auto {} 
  }
}

resource "google_secret_manager_secret_version" "benchmarks-database-ip-address" {
  secret      = google_secret_manager_secret.benchmarks-database-ip-address.id
  secret_data = module.cloudsql.private_ip_address
}

# Create a regional static IP address
resource "google_compute_address" "hatchet-benchmark-ip" {
  name         = "hatchet-benchmark-ip"
  region       = "us-west1"         # specify your region here
  address_type = "EXTERNAL"
}

output "gke_static_ip" {
  value = google_compute_address.hatchet-benchmark-ip.address
}


resource "google_secret_manager_secret" "db_password" {
  secret_id = "benchmarks-database-password-auto"
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
  instance = google_sql_database.benchmarks_database.instance
  password = google_secret_manager_secret_version.db_password_version.secret_data
}




# bunch of dummy keys to make things go easier later

resource "google_secret_manager_secret" "benchmarks-cert-manager-cloudflare-token"   {
  
  secret_id = "benchmarks-cert-manager-cloudflare-token"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "benchmarks-cert-manager-cloudflare-token" {
  secret = google_secret_manager_secret.benchmarks-cert-manager-cloudflare-token.id
  secret_data = "cf-token-dummy"
}


resource "google_secret_manager_secret" "benchmarks-logdna-ingestion-key" {
  secret_id = "benchmarks-logdna-ingestion-key"
  replication {
    auto {}
  }

}

resource "google_secret_manager_secret_version" "benchmarks-logdna-ingestion-key" {
  secret = google_secret_manager_secret.benchmarks-logdna-ingestion-key.id
  secret_data = "logdna-ingestion-key-dummy"
}

resource "google_secret_manager_secret" "metabase-benchmarks-database-password" {
  secret_id = "metabase-benchmarks-database-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "metabase-benchmarks-database-password" {
  secret = google_secret_manager_secret.metabase-benchmarks-database-password.id
  secret_data = "metabase-benchmarks-database-password-dummy"
}


resource "google_secret_manager_secret" "benchmarks-tailscale-auth-key" {
  
  secret_id = "benchmarks-tailscale-auth-key"
  replication {
    auto {}
  }  
}
resource "google_secret_manager_secret_version" "benchmarks-tailscale-auth-key" {
  secret = google_secret_manager_secret.benchmarks-tailscale-auth-key.id
  secret_data= "benchmarks-tailscale-auth-key-dummy"
  
  
}



resource "google_secret_manager_secret" "benchmarks-rabbitmq-password" {
  secret_id = "benchmarks-rabbitmq-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "benchmarks-rabbitmq-password" {
  secret = google_secret_manager_secret.benchmarks-rabbitmq-password.id
  secret_data = random_password.password.result  
}
