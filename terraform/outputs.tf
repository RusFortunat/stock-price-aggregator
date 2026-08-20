output "data_lake_bucket" {
  value = aws_s3_bucket.data_lake.bucket
}

output "athena_bucket" {
  value = aws_s3_bucket.athena.bucket
}

output "mwaa_dags_bucket" {
  value = aws_s3_bucket.mwaa.bucket
}

output "glue_raw_database" {
  value = aws_glue_catalog_database.raw.name
}

output "glue_marts_database" {
  value = aws_glue_catalog_database.marts.name
}

output "athena_workgroup" {
  value = aws_athena_workgroup.main.name
}

output "ecr_dbt_repository_url" {
  value = aws_ecr_repository.dbt.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_dbt_task_definition_arn" {
  value = aws_ecs_task_definition.dbt.arn
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "pipeline_security_group_id" {
  value = aws_security_group.pipeline.id
}

output "mwaa_webserver_url" {
  value = aws_mwaa_environment.main.webserver_url
}
