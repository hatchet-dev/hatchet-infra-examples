variable "gcp_project_id" {
  type = string
}

variable "env_name" {
  type = string
}

variable "instance" {
  type = string
  description = "The name of the GCP instance"
}

variable "namespaces" {
  type = list(string)
  description = "The list of namespaces to authorize connections from"
}