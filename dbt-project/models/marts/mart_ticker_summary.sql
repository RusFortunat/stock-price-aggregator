{{ config(
    s3_data_naming='table_unique',
    s3_data_dir=get_s3_data_dir()
) }}

SELECT
    ticker,
    MAX(price_date) AS latest_price_date,
    MAX_BY(close, price_date) AS latest_close,

    MAX(close) AS high_52w,
    MIN(close) AS low_52w,
    AVG(volume) AS avg_volume,

    AVG(volatility_30d) AS avg_volatility_30d,
    COUNT(*) AS days_tracked

FROM {{ ref('int_stock_metrics') }}
WHERE price_date >= date_add('week', -52, current_date)
GROUP BY ticker