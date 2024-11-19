variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "env_name" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_instance_type" {
  type    = string
  default = "db-custom-1-3840"
}

variable "database_deletion_protection" {
  type    = bool
  default = true
}

variable "max_connections" {
  description = "Maximum number of connections for the database instance."
  type        = number
  default     = 100 
}