resource "aws_mwaa_environment" "main" {
  name              = "${var.project_name}-mwaa"
  airflow_version   = var.mwaa_airflow_version
  environment_class = var.mwaa_environment_class
  execution_role_arn = aws_iam_role.mwaa_execution.arn

  source_bucket_arn = aws_s3_bucket.mwaa.arn
  dag_s3_path       = "dags"

  network_configuration {
    security_group_ids = [aws_security_group.pipeline.id]
    subnet_ids          = aws_subnet.private[*].id
  }

  webserver_access_mode = "PUBLIC_ONLY"

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }
    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }
    task_logs {
      enabled   = true
      log_level = "INFO"
    }
    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }
    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }

  depends_on = [aws_s3_object.mwaa_dags_prefix]
}
