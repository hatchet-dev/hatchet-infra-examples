variable "certificate_email" {
  description = "The email address to use for the certificate"
  type        = string
}

variable "cloudflare_api_token_secret" {
  description = "The name of the secret in Secret Manager that contains the Cloudflare API token"
  type        = string
  sensitive   = true
}
