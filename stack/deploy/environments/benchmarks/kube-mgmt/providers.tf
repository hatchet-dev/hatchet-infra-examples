terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.10.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
  }
}

provider "google" {
  project = "hatchet-benchmarks"
  region  = "us-west1"
}

data "google_container_cluster" "primary" {
  name     = "benchmarks-cluster"
  location = "us-west1"
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.provider.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.primary.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.provider.access_token
  }
}
