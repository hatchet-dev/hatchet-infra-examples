resource "google_sql_database_instance" "default" {
  name             = var.instance_name
  region           = var.gcp_region
  database_version = "POSTGRES_15"

  settings {
    
    tier = var.database_instance_type

    deletion_protection_enabled = false

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = var.vpc_id
      require_ssl     = "false"
    }

    # Enables IAM authentication for the instance. This is needed for Teleport auth. 
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
 
    }

    database_flags {
      name = "max_connections"
      value = var.max_connections
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true

      backup_retention_settings {
        retained_backups = 30
      }
    }

    insights_config {
      query_insights_enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.default.name
}

