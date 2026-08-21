# Stock Price Aggregator
Designed an ETL pipeline that fetches granular financial data from some public API, aggregates it into readable format, and delivers it to a Swagger API endpoint. The data is loaded with AWS Lambda, delivered to S3 datalake, transformation to buiseness marts with dbt Athena, and delivered to the user with Python script. The whole process is orchestrated on a scheduled basis with Airflow DAG. 

I will be taking data from Alpha Vantage // TODO: add href

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

## Injestion Lambda

The lambda will be fetching data from Alpha Vantage API and
storing it in S3 bucket in a raw format. The data will be stored 
in a Hive-like partitioned structure, e.g., raw/AAPL/ingestion_date=<YYYY-MM-DD>/...

Example of the get request for AAPL stock data that fetches about 100 days of daily stock data:
https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=AAPL&outputsize=compact&apikey=YOUR_API_KEY

Example of the response:
"Meta Data": {
      "1. Information": "Daily Prices (open, high, low, close) and Volumes",
      "2. Symbol": "AAPL",
      "3. Last Refreshed": "2026-08-20",
      "4. Output Size": "Compact",
      "5. Time Zone": "US/Eastern"
  },
  "Time Series (Daily)": {
      "2026-08-20": {
          "1. open": "317.3200",
          "2. high": "320.2800",
          "3. low": "310.6500",
          "4. close": "311.3000",
          "5. volume": "38316518"
      }, ...

