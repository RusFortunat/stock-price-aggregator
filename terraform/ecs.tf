resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ===========================================================
# dbt
# ===========================================================
resource "aws_ecr_repository" "dbt" {
  name                 = "${var.project_name}-dbt"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
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
  task_role_arn            = aws_iam_role.dbt_task.arn

  container_definitions = jsonencode([
    {
      name      = "dbt"
      image     = "${aws_ecr_repository.dbt.repository_url}:${var.dbt_image_tag}"
      essential = true
      environment = [
        { 
          name = "STAGING_DATABASE", 
          value = aws_glue_catalog_database.staging.name 
        },
        { 
          name = "INTERMEDIATE_DATABASE", 
          value = aws_glue_catalog_database.intermediate.name 
        },
        { 
          name = "MARTS_DATABASE", 
          value = aws_glue_catalog_database.marts.name 
        },
        { 
          name = "DBT_ATHENA_WORKGROUP", 
          value = aws_athena_workgroup.main.name 
        },
        { 
          name = "DBT_S3_STAGING_DIR", 
          value = "s3://${aws_s3_bucket.athena_temp.bucket}/athena-results/" 
        },
        { 
          name = "DBT_S3_DATA_DIR", 
          value = "s3://${aws_s3_bucket.data_lake.bucket}/" 
        },
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

# ===========================================================
# FastApi ECS Service
# ===========================================================
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ===========================================================
# dbt
# ===========================================================
resource "aws_ecr_repository" "dbt" {
  name                 = "${var.project_name}-dbt"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
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
  task_role_arn            = aws_iam_role.dbt_task.arn

  container_definitions = jsonencode([
    {
      name      = "dbt"
      image     = "${aws_ecr_repository.dbt.repository_url}:${var.dbt_image_tag}"
      essential = true
      environment = [
        { 
          name = "STAGING_DATABASE", 
          value = aws_glue_catalog_database.staging.name 
        },
        { 
          name = "INTERMEDIATE_DATABASE", 
          value = aws_glue_catalog_database.intermediate.name 
        },
        { 
          name = "MARTS_DATABASE", 
          value = aws_glue_catalog_database.marts.name 
        },
        { 
          name = "DBT_ATHENA_WORKGROUP", 
          value = aws_athena_workgroup.main.name 
        },
        { 
          name = "DBT_S3_STAGING_DIR", 
          value = "s3://${aws_s3_bucket.athena_temp.bucket}/athena-results/" 
        },
        { 
          name = "DBT_S3_DATA_DIR", 
          value = "s3://${aws_s3_bucket.data_lake.bucket}/" 
        },
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

# ===========================================================
# FastApi python server
# ===========================================================
resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.pipeline.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.api_http]
}

resource "aws_ecr_repository" "api" {
  name                 = "${var.project_name}-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project_name}-api"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.api_task.arn

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = "${aws_ecr_repository.api.repository_url}:${var.api_image_tag}"
      essential = true
      portMappings = [
        { containerPort = 8000, protocol = "tcp" }
      ]
      environment = [
        { name = "MARTS_DATABASE", value = aws_glue_catalog_database.marts.name },
        { name = "ATHENA_WORKGROUP", value = aws_athena_workgroup.main.name },
        { name = "ATHENA_STAGING_DIR", value = "s3://${aws_s3_bucket.data_lake.bucket}/athena-results/" },
        { name = "AWS_REGION", value = var.aws_region }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "api"
        }
      }
    }
  ])
}
