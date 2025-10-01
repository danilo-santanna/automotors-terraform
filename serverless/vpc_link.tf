
data "aws_lb" "orders_nlb" {
  name = var.orders_nlb_name
}

data "aws_lb_listener" "orders_80" {
  load_balancer_arn = data.aws_lb.orders_nlb.arn
  port              = 80
}

resource "aws_apigatewayv2_vpc_link" "eks" {
  name               = "${local.name_prefix}-vpc-link"
  subnet_ids         = data.terraform_remote_state.infra.outputs.private_subnets
  security_group_ids = [aws_security_group.apigw_to_nlb.id]
  tags               = local.tags
}

resource "aws_apigatewayv2_integration" "orders_integ" {
  api_id                 = aws_apigatewayv2_api.edge.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.eks.id
  integration_uri        = data.aws_lb_listener.orders_80.arn
  payload_format_version = "1.0"
}

data "aws_vpc" "this" {
  id = data.terraform_remote_state.infra.outputs.vpc_id
}

resource "aws_security_group" "apigw_to_nlb" {
  name        = "apigw-to-nlb"
  description = "Traffic from API Gateway VPC Link to EKS nodes (NodePort)"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "apigw-to-nlb" }
}

resource "aws_security_group_rule" "allow_apigw_to_nodes" {
  type              = "ingress"
  from_port         = 32453
  to_port           = 32453
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  security_group_id = data.terraform_remote_state.infra.outputs.node_sg_id
  description       = "API Gateway"
}

resource "aws_apigatewayv2_route" "payments_proxy" {
  api_id    = aws_apigatewayv2_api.edge.id
  route_key = "ANY /payments/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.orders_integ.id}"
}