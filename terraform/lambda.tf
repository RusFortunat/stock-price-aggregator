resource "aws_lambda_function" "ingestion" {
  function_name = "ingestion-lambda"
  runtime       = "nodejs24.x"
  handler       = "handler.handler"

  filename         = "../ingestion-lambda/dist/lambda.zip"
  source_code_hash = filebase64sha256("../ingestion-lambda/dist/lambda.zip")

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.data_lake.bucket
      ALPHA_VANTAGE_API_KEY = var.alpha_vantage_api_key
    }
  }
}