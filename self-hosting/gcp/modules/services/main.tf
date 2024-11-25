resource "google_project_service" "compute" {
  project = var.gcp_project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.gcp_project_id
  service = "container.googleapis.com"
}

resource "google_project_service" "cloudresourcemanager" {
  project = var.gcp_project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  project = var.gcp_project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "servicenetworking" {
  project = var.gcp_project_id
  service = "servicenetworking.googleapis.com"
}

resource "google_project_service" "sqladmin" {
  project = var.gcp_project_id
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "secretmanager" {
  project = var.gcp_project_id
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "adminsdk" {
  project = var.gcp_project_id
  service = "admin.googleapis.com"
}

resource "google_project_service" "cloudasset" {
  project = var.gcp_project_id
  service = "cloudasset.googleapis.com"
}

resource "google_project_service" "policyanalyzer" {
  project = var.gcp_project_id
  service = "policyanalyzer.googleapis.com"
}

resource "google_project_service" "admin" {
  project = var.gcp_project_id
  service = "admin.googleapis.com"
}
