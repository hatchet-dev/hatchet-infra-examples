output "database_instance_name" {
  value = google_sql_database_instance.default.name
}

output "private_ip_address" {
  value       = google_sql_database_instance.default.ip_address[0].ip_address
  description = "The private IP address of the Cloud SQL instance."
}
