# Create a service account for encrypting/decrypting via CloudKMS
module "cloudkms_service_account" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 3.0"

  project_id   = var.gcp_project_id
  display_name = "${var.env_name} cloudkms user"
  names = [
    "${var.env_name}-cloudkms-user"
  ]
  description   = "Service account used by Hatchet to authenticate with CloudKMS."
  generate_keys = false

  project_roles = [
    "${var.gcp_project_id}=>roles/cloudkms.cryptoKeyEncrypterDecrypter",
  ]
}
