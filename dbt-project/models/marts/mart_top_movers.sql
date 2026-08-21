{{ config(
    s3_data_naming='table_unique',
    s3_data_dir=get_s3_data_dir(),
    partitioned_by=['price_date']
) }}

SELECT
    ticker,
    price_date,
    close,
    daily_return,
    volatility_30d,
    RANK() OVER (
        PARTITION BY price_date ORDER BY daily_return DESC
    ) AS gainer_rank,
    RANK() OVER (
        PARTITION BY price_date ORDER BY daily_return ASC
    ) AS loser_rank
FROM {{ ref('int_stock_metrics') }}
WHERE daily_return IS NOT NULL