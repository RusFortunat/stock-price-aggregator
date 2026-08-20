resource "aws_lambda_function" "ingestion" {
  function_name = "ingestion-lambda"
  runtime       = "nodejs24.x"
  handler       = "handler.handler"

  filename         = "../ingestion-lambda/dist/lambda.zip"
  source_code_hash = filebase64sha256("../ingestion-lambda/dist/lambda.zip")

  role = aws_iam_role.lambda_role.arn
}