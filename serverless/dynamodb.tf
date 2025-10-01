resource "aws_dynamodb_table" "payments_dedupe" {
  name         = "${local.name_prefix}-payments-dedupe"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "payment_id"

  attribute {
    name = "payment_id"
    type = "S"
  }
  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = local.tags
}
