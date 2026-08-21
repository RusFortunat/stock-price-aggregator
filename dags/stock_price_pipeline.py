from datetime import datetime
from airflow import DAG
from airflow.providers.amazon.aws.operators.lambda_function import LambdaInvokeFunctionOperator
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.providers.amazon.aws.operators.glue_crawler import GlueCrawlerOperator

# Define the DAG (Directed Acyclic Graph) 
with DAG(
    dag_id="stock_price_pipeline",
    schedule_interval="0 12 * * *",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["stock-price-aggregator"],
) as dag:
 
    ingest = LambdaInvokeFunctionOperator(
        task_id="ingest_stock_prices",
        function_name="stock-price-aggregator-ingestion",
        payload='{"ticker": "AAPL"}',  # TODO: loop/mapped task per ticker
    )
 
    crawl_raw = GlueCrawlerOperator(
        task_id="crawl_raw_data",
        config={"Name": "stock-price-aggregator-raw-crawler"},
        wait_for_completion=True,  # blocks until the crawler finishes before dbt runs
    )
 
    run_dbt = EcsRunTaskOperator(
        task_id="run_dbt_transform",
        cluster="stock-price-aggregator-cluster",
        task_definition="stock-price-aggregator-dbt",
        launch_type="FARGATE",
        overrides={
            "containerOverrides": [
                {"name": "dbt", "command": ["dbt", "run", "--target", "prod"]}
            ]
        },
        network_configuration={
            "awsvpcConfiguration": {
                "subnets": ["<private_subnet_ids from terraform output>"],
                "securityGroups": ["<pipeline_security_group_id from terraform output>"],
                "assignPublicIp": "DISABLED",
            }
        },
        awslogs_group="/ecs/stock-price-aggregator-dbt",
        awslogs_stream_prefix="ecs/dbt",
    )

    # That's the DAG definition
    ingest >> crawl_raw >> run_dbt