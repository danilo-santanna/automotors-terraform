resource "aws_iam_role" "stepfn_role" {
  name = "${local.name_prefix}-stepfn"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect="Allow", Principal={ Service="states.amazonaws.com" }, Action="sts:AssumeRole" }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "stepfn_invoke" {
  role       = aws_iam_role.stepfn_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

resource "aws_sfn_state_machine" "purchase_saga" {
  name     = "${local.name_prefix}-purchase-saga"
  role_arn = aws_iam_role.stepfn_role.arn

  definition = jsonencode({
    Comment = "Automotors purchase saga",
    StartAt = "CreateOrder",
    States = {
      CreateOrder = {
        Type     = "Task",
        Resource = aws_lambda_function.create_order.arn,
        Next     = "ReserveVehicle",
        Catch    = [{ ErrorEquals=["States.ALL"], Next="ReleaseVehicle" }]
      },
      ReserveVehicle = {
        Type     = "Task",
        Resource = aws_lambda_function.reserve_vehicle.arn,
        Next     = "TakePayment",
        Catch    = [{ ErrorEquals=["States.ALL"], Next="Fail" }]
      },
      TakePayment = {
        Type     = "Task",
        Resource = aws_lambda_function.take_payment.arn,
        Next     = "MarkSold",
        Catch    = [{ ErrorEquals=["PaymentFailed"], Next="CancelAndRelease" }]
      },
      MarkSold = {
        Type     = "Task",
        Resource = aws_lambda_function.mark_sold.arn,
        End      = true
      },
      CancelAndRelease = {
        Type = "Parallel",
        Branches = [
          {
            StartAt = "CancelOrder",
            States  = {
              CancelOrder = {
                Type     = "Task",
                Resource = aws_lambda_function.cancel_order.arn,
                End      = true
              }
            }
          },
          {
            StartAt = "ReleaseVehicleOnCancel",
            States  = {
              ReleaseVehicleOnCancel = {
                Type     = "Task",
                Resource = aws_lambda_function.release_vehicle.arn,
                End      = true
              }
            }
          }
        ],
        Next = "Fail"
      },
      ReleaseVehicle = {
        Type     = "Task",
        Resource = aws_lambda_function.release_vehicle.arn,
        Next     = "Fail"
      },
      Fail = { Type = "Fail" }
    }
  })

  tags = local.tags
}


data "aws_caller_identity" "current" {}
