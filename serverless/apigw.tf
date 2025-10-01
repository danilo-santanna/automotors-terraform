resource "aws_apigatewayv2_api" "edge" {
  name          = "${local.name_prefix}-edge"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
    expose_headers = ["*"]
    max_age = 3600
  }

  tags = local.tags
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.edge.id
  name        = "$default"
  auto_deploy = true
  tags        = local.tags
}

resource "aws_apigatewayv2_route" "orders_proxy" {
  api_id    = aws_apigatewayv2_api.edge.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.orders_integ.id}"
}

