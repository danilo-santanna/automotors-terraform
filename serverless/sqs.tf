resource "aws_sqs_queue" "webhook_dlq" {
  name                      = "${local.name_prefix}-webhook-dlq"
  message_retention_seconds = 1209600
  tags                      = local.tags
}

resource "aws_sqs_queue" "webhook_queue" {
  name                       = "${local.name_prefix}-webhook"
  visibility_timeout_seconds = 60
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.webhook_dlq.arn
    maxReceiveCount     = 5
  })
  tags = local.tags
}
