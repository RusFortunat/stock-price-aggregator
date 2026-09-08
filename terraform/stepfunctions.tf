resource "aws_sfn_state_machine" "pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.stepfunctions_execution.arn

  definition = templatefile("${path.module}/stepfunctions/etl-workflow.asl.json", 
  {
    lambda_arn        = aws_lambda_function.ingestion.arn
    ecs_cluster_arn   = aws_ecs_cluster.main.arn
    dbt_task_def_arn  = aws_ecs_task_definition.dbt.arn
    crawler_name      = aws_glue_crawler.raw.name
    subnet_ids        = jsonencode(aws_subnet.private[*].id)
    security_group_id = aws_security_group.pipeline.id
  })
}