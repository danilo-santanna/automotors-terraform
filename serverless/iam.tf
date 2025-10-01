data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_webhook_role" {
  name               = "${local.name_prefix}-lambda-webhook"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_webhook_logs" {
  role       = aws_iam_role.lambda_webhook_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permissões para enviar ao SQS
resource "aws_iam_policy" "lambda_webhook_sqs" {
  name = "${local.name_prefix}-webhook-sqs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["sqs:SendMessage"],
      Resource = [aws_sqs_queue.webhook_queue.arn]
    }]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_webhook_sqs_attach" {
  role       = aws_iam_role.lambda_webhook_role.name
  policy_arn = aws_iam_policy.lambda_webhook_sqs.arn
}

# Consumer
resource "aws_iam_role" "lambda_consumer_role" {
  name               = "${local.name_prefix}-lambda-consumer"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = local.tags
}
resource "aws_iam_role_policy_attachment" "lambda_consumer_logs" {
  role       = aws_iam_role.lambda_consumer_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_policy" "lambda_consumer_sqs" {
  name = "${local.name_prefix}-consumer-sqs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
      Resource = [aws_sqs_queue.webhook_queue.arn]
    }]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_consumer_sqs_attach" {
  role       = aws_iam_role.lambda_consumer_role.name
  policy_arn = aws_iam_policy.lambda_consumer_sqs.arn
}

resource "aws_iam_role" "saga_lambda_exec" {
  name = "${local.name_prefix}-saga-lambda-exec"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "saga_basic_logs" {
  role       = aws_iam_role.saga_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

