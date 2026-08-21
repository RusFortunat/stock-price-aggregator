{{ config(
    s3_data_naming='table_schema',
    s3_data_dir=get_s3_data_dir(),
    partitioned_by=['price_date']
) }}

WITH daily_returns AS (
    SELECT
        *,
        (close - LAG(close) OVER (PARTITION BY ticker ORDER BY price_date))
            / LAG(close) OVER (PARTITION BY ticker ORDER BY price_date) AS daily_return
    FROM {{ ref('stg_stock_prices') }}
)

SELECT
    ticker,
    price_date,
    close,
    volume,
    daily_return,

    -- rolling averages (SMA)
    AVG(close) OVER (
        PARTITION BY ticker ORDER BY price_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS sma_7d,
    AVG(close) OVER (
        PARTITION BY ticker ORDER BY price_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS sma_30d,

    -- volatility: stddev of daily returns, not raw price
    STDDEV(daily_return) OVER (
        PARTITION BY ticker ORDER BY price_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS volatility_30d

FROM daily_returns