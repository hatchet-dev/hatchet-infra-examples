variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "env_name" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "override_node_zones" {
  type    = list(string)
  default = []
}
