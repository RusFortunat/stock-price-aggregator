# =======================================================================
# Ingestion Lambda
# =======================================================================
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# =======================================================================
# Athena
# =======================================================================
resource "aws_iam_role" "athena_workgroup" {
  name = "${var.project_name}-athena-workgroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "athena.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "athena_s3" {
  name = "${var.project_name}-athena-s3"
  role = aws_iam_role.athena_workgroup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "s3:GetObject", 
        "s3:PutObject", 
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.athena_temp.arn,
        "${aws_s3_bucket.athena_temp.arn}/query-results/*"
      ]
    }]
  })
}

# =======================================================================
# Glue
# =======================================================================
resource "aws_iam_role" "glue_crawler" {
  name = "${var.project_name}-glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_crawler_s3" {
  name = "${var.project_name}-glue-crawler-s3"
  role = aws_iam_role.glue_crawler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "s3:GetObject", 
        "s3:PutObject", 
        "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.data_lake.arn,
        "${aws_s3_bucket.data_lake.arn}/raw/*"
      ]
    }]
  })
}

# =======================================================================
# ECS DBT
# =======================================================================
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- Task role: what the dbt container itself can do (Athena/Glue/S3) ---
resource "aws_iam_role" "dbt_task" {
  name = "${var.project_name}-dbt-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "dbt_task" {
  name = "${var.project_name}-dbt-task-policy"
  role = aws_iam_role.dbt_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AthenaQuery"
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StopQueryExecution",
          "athena:GetWorkGroup"
        ]
        Resource = "*"
      },
      {
        Sid    = "GlueCatalog"
        Effect = "Allow"
        Action = [
          "glue:GetDatabase", 
          "glue:GetDatabases",
          "glue:GetTable", 
          "glue:GetTables", 
          "glue:GetPartitions",

          "glue:CreateTable", 
          "glue:UpdateTable", 
          "glue:DeleteTable",

          "glue:BatchCreatePartition", 
          "glue:BatchDeletePartition"
        ]
        Resource = "*"
      },
      {
        Sid    = "DataLakeAndResultsBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject", 
          "s3:PutObject", 
          "s3:ListBucket", 
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.data_lake.arn,
          "${aws_s3_bucket.data_lake.arn}/*",
          aws_s3_bucket.athena.arn,
          "${aws_s3_bucket.athena.arn}/*"
        ]
      }
    ]
  })
}
