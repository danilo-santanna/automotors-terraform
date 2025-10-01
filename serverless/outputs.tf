output "webhook_url" {
  description = "Use isto como PUBLIC_BASE_URL no orders-service (sem /payments/webhook no final)"
  value       = aws_apigatewayv2_api.webhook.api_endpoint
}

output "api_invoke_url" {
  value = aws_apigatewayv2_api.edge.api_endpoint
}

output "orders_via_apigw_example" {
  value = "${aws_apigatewayv2_api.edge.api_endpoint}/orders/actuator/health"
}
