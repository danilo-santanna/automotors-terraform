resource "aws_wafv2_web_acl" "edge_waf" {
  name        = "${local.name_prefix}-edge-waf"
  description = "Protege API Gateway"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-edge-waf"
    sampled_requests_enabled   = true
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common"
      sampled_requests_enabled   = true
    }
  }
  tags = local.tags
}

#resource "aws_wafv2_web_acl_association" "edge_assoc" {
 #resource_arn = aws_apigatewayv2_stage.default.arn
  #web_acl_arn  = aws_wafv2_web_acl.edge_waf.arn
#}
