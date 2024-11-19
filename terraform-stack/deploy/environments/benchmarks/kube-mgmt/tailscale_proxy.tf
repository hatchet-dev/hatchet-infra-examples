data "google_secret_manager_secret_version" "tailscale_auth_key" {
  project = "hatchet-benchmarks"
  secret  = "benchmarks-tailscale-auth-key"
}

module "tailscale-proxy" {
  # Note: change this to a module registry or remote file URL. 
  source = "../../../../modules/tailscale/tailscale-proxy"

  # This is the hostname which determines how the proxy will appear in the Tailscale admin list of machines
  tailscale_hostname = "benchmarks-proxy"

  dest_ip = data.kubernetes_service.nginx_ingress_private.spec[0].cluster_ip

  tailscale_auth_key = data.google_secret_manager_secret_version.tailscale_auth_key.secret_data
}
