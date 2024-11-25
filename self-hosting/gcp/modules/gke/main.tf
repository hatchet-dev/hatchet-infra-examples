data "google_compute_zones" "available" {
  region = var.gcp_region
}

locals {
  # Node location
  node_location = length(var.override_node_zones) > 0 ? var.override_node_zones : (length(data.google_compute_zones.available) > 2 ? [
    data.google_compute_zones.available.names[0],
    data.google_compute_zones.available.names[1],
    data.google_compute_zones.available.names[2],
    ] : [
    data.google_compute_zones.available.names[0],
    data.google_compute_zones.available.names[1],
  ])
}

resource "google_container_cluster" "primary" {
  name           = "${var.env_name}-cluster"
  location       = var.gcp_region
  node_locations = local.node_location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  logging_service          = "none"
  monitoring_service       = "none"

  network    = var.vpc_name
  subnetwork = var.subnet_name

  # probably want to change in a production deployment
  deletion_protection = false

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  cluster_autoscaling {
    # Turn off node-autoprovisioning so we can use our own node group
    enabled = true

    resource_limits {
      resource_type = "cpu"
      minimum       = 6
      maximum       = 150
    }

    resource_limits {
      resource_type = "memory"
      minimum       = 12
      maximum       = 300
    }
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "system" {
  name           = "${var.env_name}-system-pool"
  cluster        = google_container_cluster.primary.name
  location       = var.gcp_region
  node_count     = 1
  node_locations = local.node_location

  node_config {
    machine_type = "custom-2-4096"

    labels = {
      "hatchet.run/workload-kind" = "system"
    }

    taint {
      key    = "hatchet.run/workload-kind"
      value  = "system"
      effect = "NO_SCHEDULE"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
