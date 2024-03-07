resource "aws_sns_topic_subscription" "this" {
  topic_arn = var.aws_topic_arn
  protocol  = "https"
  endpoint  = var.hatchet_ingest_url
}
