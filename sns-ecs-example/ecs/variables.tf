variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "env_name" {
  type    = string
  default = "development"
}

variable "hatchet_token" {
  type        = string
  description = "The token for the Hatchet service"
  sensitive   = true
}

variable "vpc_cidr" {
  description = "CIDR block for main"
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_image_url" {
  type        = string
  description = "The URL of the container image"
}
