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

variable "hatchet_server_url" {
  description = "The URL of the Hatchet server"
  type        = string
}

variable "hatchet_engine_url" {
  description = "The URL of the Hatchet engine"
  type        = string
}
