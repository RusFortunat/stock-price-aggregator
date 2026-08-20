# Stock Price Aggregator
Designed a pipeline that fetches granular financial data from some public API, aggregates it into readable format, and delivers it to a Swagger API endpoint. The data is loaded with AWS Lambda, delivered to S3 datalake, transformation to buiseness marts with dbt Athena, and delivered to the user with Python script. The whole process is orchestrated on a scheduled basis with Airflow DAG. 


## Workflow draft

                 ┌─────────────────────┐
                 │   Public Stock API  │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │   ingestion-lambda  │
                 │     TypeScript      │
                 └──────────┬──────────┘
                            │ raw JSON
                            ▼
                 ┌─────────────────────┐
                 │        S3           │
                 │    Raw data lake    │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │     dbt + Athena    │
                 │   Transform / SQL   │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │       Athena        │
                 │  Analytical tables  │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │       FastAPI       │
                 │       main.py       │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      Swagger UI     │
                 └─────────────────────┘