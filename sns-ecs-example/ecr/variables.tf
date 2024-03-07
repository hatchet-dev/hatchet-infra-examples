variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "ecr_name" {
  type        = string
  description = "The name of the ECR repository"
}
