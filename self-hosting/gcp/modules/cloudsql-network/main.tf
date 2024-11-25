data "google_compute_network" "main" {
  name = var.vpc_name

  project = var.gcp_project_id
}

// We define a VPC peering subnet that will be peered with the
// Cloud SQL instance network. The Cloud SQL instance will
// have a private IP within the provided range.
// https://cloud.google.com/vpc/docs/configure-private-services-access
resource "google_compute_global_address" "google-managed-services-range" {
  project       = var.gcp_project_id
  name          = "google-managed-services-${data.google_compute_network.main.name}"
  purpose       = "VPC_PEERING"
  prefix_length = 16
  address_type  = "INTERNAL"
  network       = data.google_compute_network.main.self_link
}

# Creates the peering with the producer network.
resource "google_service_networking_connection" "private_service_access" {
  network                 = var.vpc_name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.google-managed-services-range.name]
}

resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.private_service_access.peering
  network              = data.google_compute_network.main.name
  import_custom_routes = true
  export_custom_routes = true
}