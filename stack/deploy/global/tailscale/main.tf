module "tailscale-admin" {
  # Note: change this to a module registry or remote file URL. 
  source = "../../../modules/tailscale/tailscale-admin"

  engineering_users = [
    "alexander@hatchet.run",
    "gabe@hatchet.run",
  ]
}
