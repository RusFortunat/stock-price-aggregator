resource "aws_athena_workgroup" "main" {
  name = "${var.project_name}-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    // TODO: is this correct? Should we use the Athena bucket for query results instead?
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_temp.bucket}/query-results/"
    }
  }
}