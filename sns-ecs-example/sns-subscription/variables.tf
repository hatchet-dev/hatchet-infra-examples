variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "aws_topic_arn" {
  type        = string
  description = "The topic ARN created previously"
}

variable "hatchet_ingest_url" {
  type        = string
  description = "The URL of the Hatchet service"
}

