module "gcp_services" {
  # Note: change this to a module registry or remote file URL. 
  source = "../../../../modules/gcp/services"

  gcp_project_id = "hatchet-benchmarks"
}
