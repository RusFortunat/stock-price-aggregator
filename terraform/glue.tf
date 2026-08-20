resource "aws_glue_catalog_database" "raw" {
  name        = replace("${var.project_name}_raw", "-", "_")
  description = "Raw landing zone tables for ingested stock price data"
}

resource "aws_glue_catalog_database" "staging" {
  name        = replace("${var.project_name}_staging", "-", "_")
  description = "Data cleanup"
}

resource "aws_glue_catalog_database" "intermediate" {
  name        = replace("${var.project_name}_intermediate", "-", "_")
  description = "Intermediate tables for data processing"
}

resource "aws_glue_catalog_database" "marts" {
  name        = replace("${var.project_name}_marts", "-", "_")
  description = "business-ready marts: rolling averages, volatility metrics"
}

// TODO: i will store data in Hive format, i.e., raw/ingestion_date=<YYYY-MM-DD>/...
// crawler will be going inside today's subfolder
resource "aws_glue_crawler" "raw" {
  name          = "${var.project_name}-raw-crawler"
  role          = aws_iam_role.glue_crawler.arn
  database_name = aws_glue_catalog_database.raw.name

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.bucket}/raw/"
  }

  // TODO: I typically do this as a part of orchestrated workflow
  //schedule = "cron(0 11 * * ? *)" # daily, shortly after the ingestion Lambda runs

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }
}