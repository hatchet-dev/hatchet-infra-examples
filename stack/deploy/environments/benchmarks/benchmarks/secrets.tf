# data "google_secret_manager_secret_version" "database_url" {
#   project = "hatchet-benchmarks"
#   secret  = "benchmarks-database-url"
# }

# data "google_secret_manager_secret_version" "database_password" {
#   project = "hatchet-benchmarks"
#   secret  = "benchmarks-database-password"
# }

# data "google_secret_manager_secret_version" "server_auth_cookie_secrets" {
#   project = "hatchet-benchmarks"
#   secret  = "benchmarks-server-auth-cookie-secrets"
# }

data "google_secret_manager_secret_version" "rabbitmq_password" {
  project = "hatchet-benchmarks"
  secret = "benchmarks-rabbitmq-password"
}

# data "google_secret_manager_secret_version" "google_client_id" {
#   project = "hatchet-benchmarks"
#   secret = "benchmarks-google-client-id"
# }

# data "google_secret_manager_secret_version" "google_client_secret" {
#   project = "hatchet-benchmarks"
#   secret = "benchmarks-google-client-secret"
# }

# data "google_secret_manager_secret_version" "cloudkms_credentials" {
#   project = "hatchet-benchmarks"
#   secret = "benchmarks-cloudkms-key"
# }

# data "google_secret_manager_secret_version" "jwt_private_keyset" {
#   project = "hatchet-benchmarks"
#   secret = "benchmarks-jwt-private-keyset"
# }

# data "google_secret_manager_secret_version" "jwt_public_keyset" {
#   project = "hatchet-benchmarks"
#   secret = "benchmarks-jwt-public-keyset"
# }

# data "google_secret_manager_secret_version" "postmark_api_token" {
#   project = "hatchet-benchmarks"
#   secret = "benchmarks-postmark-api-token"
# }

# data "google_secret_manager_secret_version" "slack_client_id" {
#   project = "hatchet-benchmarks"
#   secret = "benchmarks-slack-client-id"
# }

# data "google_secret_manager_secret_version" "slack_client_secret" {
#   project = "hatchet-benchmarks"
#   secret = "benchmarks-slack-client-secret"
# }
