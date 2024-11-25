module "certificate-issuer" {
  source = "../modules/certificate-issuer"

  certificate_email           = var.certificate_email
  cloudflare_api_token_secret = var.cloudflare_api_token_secret
}

module "hatchet" {
  depends_on = [module.certificate-issuer]

  source = "../modules/hatchet"

  project            = var.project
  region             = var.region
  env_name           = var.env_name
  hatchet_server_url = var.hatchet_server_url
  hatchet_engine_url = var.hatchet_engine_url
}
