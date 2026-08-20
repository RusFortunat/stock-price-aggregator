locals {
  data_lake_bucket_name = "${var.project_name}-data-lake-${data.aws_caller_identity.current.account_id}"
  athena_bucket_name = "${var.project_name}-athena-temp-${data.aws_caller_identity.current.account_id}"
  mwaa_bucket_name       = "${var.project_name}-mwaa-${data.aws_caller_identity.current.account_id}"
}

# Data lake bucket: 
# - landing zone for the ingestion Lambda
# - storage for data processed with dbt
resource "aws_s3_bucket" "data_lake" {
  bucket = local.data_lake_bucket_name
}

resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket                  = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "data_lake_prefix" {
  bucket  = aws_s3_bucket.data_lake.id
  key     = "raw/"
  content = ""
}

# Athena bucket: temporary storage for query results
# TODO: add lifecycle rule to delete objects after 7 days
resource "aws_s3_bucket" "athena_temp" {
  bucket = local.athena_bucket_name
}

resource "aws_s3_bucket_versioning" "athena_temp" {
  bucket = aws_s3_bucket.athena_temp.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_temp" {
  bucket = aws_s3_bucket.athena_temp.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "athena_temp" {
  bucket                  = aws_s3_bucket.athena_temp.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "athena_prefix" {
  bucket  = aws_s3_bucket.athena_temp.id
  key     = "temp/"
  content = ""
}

# MWAA bucket: DAGs, requirements.txt, plugins
resource "aws_s3_bucket" "mwaa" {
  bucket = local.mwaa_bucket_name
}

resource "aws_s3_bucket_versioning" "mwaa" {
  bucket = aws_s3_bucket.mwaa.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mwaa" {
  bucket = aws_s3_bucket.mwaa.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "mwaa" {
  bucket                  = aws_s3_bucket.mwaa.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "mwaa_dags_prefix" {
  bucket  = aws_s3_bucket.mwaa.id
  key     = "dags/"
  content = ""
}
