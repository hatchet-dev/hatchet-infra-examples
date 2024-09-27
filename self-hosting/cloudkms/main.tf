resource "google_kms_key_ring" "keyring" {
  name     = var.env_name
  location = "global"
}

resource "google_kms_crypto_key" "crypto_key" {
  name            = var.env_name
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

module "cloudkms_service_account" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 3.0"

  project_id   = var.gcp_project_id
  display_name = "${var.env_name} Hatchet CloudKMS"
  names = [
    "${var.env_name}-hatchet-cloudkms-user"
  ]
  description   = "Service account used by Hatchet to authenticate with CloudKMS."
  generate_keys = false

  project_roles = [
    "${var.gcp_project_id}=>roles/cloudkms.cryptoKeyEncrypterDecrypter",
  ]
}
