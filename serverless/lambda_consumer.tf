resource "aws_lambda_function" "webhook_consumer" {
  function_name = "${local.name_prefix}-webhook-consumer"
  role          = aws_iam_role.lambda_consumer_role.arn
  runtime       = "python3.12"
  handler       = "consumer.handler"

  filename         = "lambda_consumer.zip"
  source_code_hash = filebase64sha256("lambda_consumer.zip")

  environment {
    variables = {
      ORDERS_WEBHOOK_URL = "${aws_apigatewayv2_api.edge.api_endpoint}/orders/payments/webhook"
    }
  }
  tags = local.tags
}

resource "aws_lambda_event_source_mapping" "sqs_to_consumer" {
  event_source_arn                   = aws_sqs_queue.webhook_queue.arn
  function_name                      = aws_lambda_function.webhook_consumer.arn
  batch_size                         = 5
  maximum_batching_window_in_seconds = 5
  enabled                            = true
}

