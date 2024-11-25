module "kube-mgmt" {
  source = "../modules/kube-mgmt"

  project  = var.project
  region   = var.region
  env_name = var.env_name
}
