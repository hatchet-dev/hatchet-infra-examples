variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "env_name" {
  description = "The environment name"
  type        = string
}

variable "certificate_email" {
  description = "The email address to use for the certificate"
  type        = string
}

variable "cloudflare_api_token_secret" {
  description = "The name of the secret in Secret Manager that contains the Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "hatchet_server_url" {
  description = "The URL of the Hatchet server"
  type        = string
}

variable "hatchet_engine_url" {
  description = "The URL of the Hatchet engine"
  type        = string
}
