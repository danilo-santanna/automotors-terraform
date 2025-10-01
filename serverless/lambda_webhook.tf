resource "aws_lambda_function" "mp_webhook" {
  function_name = "${local.name_prefix}-mp-webhook"
  role          = aws_iam_role.lambda_webhook_role.arn
  runtime       = "python3.12"
  handler       = "index.handler"

  filename         = "lambda_webhook.zip"
  source_code_hash = filebase64sha256("lambda_webhook.zip")

  environment {
    variables = {
      QUEUE_URL         = aws_sqs_queue.webhook_queue.url
    }
  }
  tags = local.tags
}

# API Gateway → Lambda (rota do webhook)
resource "aws_apigatewayv2_integration" "webhook_integ" {
  api_id                 = aws_apigatewayv2_api.edge.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.mp_webhook.invoke_arn
  payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "webhook_route" {
  api_id    = aws_apigatewayv2_api.edge.id
  route_key = "POST /payments/webhook"
  target    = "integrations/${aws_apigatewayv2_integration.webhook_integ.id}"
}
resource "aws_lambda_permission" "apigw_to_webhook" {
  statement_id  = "AllowAPIGWInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mp_webhook.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.edge.execution_arn}/*/*/payments/webhook"
}
