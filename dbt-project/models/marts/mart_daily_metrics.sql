{{ config(
    s3_data_naming='table_unique',
    s3_data_dir=get_s3_data_dir(),
    partitioned_by=['price_date']
) }}

SELECT
    ticker,
    price_date,
    close,
    volume,
    daily_return,
    sma_7d,
    sma_30d,
    volatility_30d
FROM {{ ref('int_stock_metrics') }}