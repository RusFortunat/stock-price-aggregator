resource "aws_ecr_repository" "dbt" {
  name                 = "${var.project_name}-dbt"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "dbt" {
  name              = "/ecs/${var.project_name}-dbt"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "dbt" {
  family                   = "${var.project_name}-dbt"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn             = aws_iam_role.dbt_task.arn

  container_definitions = jsonencode([
    {
      name      = "dbt"
      image     = "${aws_ecr_repository.dbt.repository_url}:${var.dbt_image_tag}"
      essential = true
      environment = [
        { name = "DBT_ATHENA_DATABASE", value = aws_glue_catalog_database.marts.name },
        { name = "DBT_ATHENA_WORKGROUP", value = aws_athena_workgroup.main.name },
        { name = "DBT_S3_STAGING_DIR", value = "s3://${aws_s3_bucket.data_lake.bucket}/athena-results/" },
        { name = "AWS_REGION", value = var.aws_region }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.dbt.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "dbt"
        }
      }
    }
  ])
}
