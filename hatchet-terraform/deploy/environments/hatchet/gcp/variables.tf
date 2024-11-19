variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}


variable "database_instance_type" {
  description = "The database instance type"
  type        = string
  default = "db-custom-16-15360"
}

variable "database_max_connections" {
  description = "The maximum number of connections for the database instance"
  type        = number
  default     = 800
}