terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ZIP da Lambda (pega tudo de lambda-webhook/)
data "archive_file" "webhook_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-webhook"
  output_path = "${path.module}/build/webhook.zip"
}

# IAM da Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project}-webhook-lambda-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Permissões básicas de log
resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# (Opcional) Log group com retenção
resource "aws_cloudwatch_log_group" "webhook" {
  name              = "/aws/lambda/${var.project}-payments-webhook"
  retention_in_days = 14
}

# Função Lambda
resource "aws_lambda_function" "webhook" {
  function_name    = "${var.project}-payments-webhook"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.webhook_zip.output_path
  source_code_hash = data.archive_file.webhook_zip.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL          = "INFO"
      ORDERS_WEBHOOK_URL = "http://a0efd2dfe2394459eae0569ffb10eaa2-1138817206.us-east-1.elb.amazonaws.com/payments/webhook"
    }
  }
}

# API Gateway HTTP (mais barato e simples)
resource "aws_apigatewayv2_api" "webhook" {
  name          = "${var.project}-webhook-api"
  protocol_type = "HTTP"
}

# Integração Lambda proxy
resource "aws_apigatewayv2_integration" "webhook" {
  api_id                 = aws_apigatewayv2_api.webhook.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.webhook.invoke_arn
  payload_format_version = "2.0"
}

# Rota POST /payments/webhook
resource "aws_apigatewayv2_route" "webhook" {
  api_id    = aws_apigatewayv2_api.webhook.id
  route_key = "POST /payments/webhook"
  target    = "integrations/${aws_apigatewayv2_integration.webhook.id}"
}

# Permissão para o API Gateway invocar a Lambda
resource "aws_lambda_permission" "apigw_invoke_webhook" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webhook.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.webhook.execution_arn}/*/*"
}
