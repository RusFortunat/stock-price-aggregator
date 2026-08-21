{{ config (
    s3_data_naming='table_schema',
    s3_data_dir=get_s3_data_dir(),
    partitioned_by=['processing_date']
)
}}

-- Data cleanup:
-- 1. remove rows with null values
-- 2. deduplicate rows based on the primary key (ticker, date)
-- 3. cast columns to the correct data types
SELECT
    s.ticker,
    CAST(s.date AS date) AS price_date,
    CAST(s.open AS double)  AS open,
    CAST(s.high AS double)  AS high,
    CAST(s.low AS double)   AS low,
    CAST(s.close AS double) AS close,
    CAST(s.volume AS bigint) AS volume,
    current_date AS processing_date -- audit column: when dbt loaded this row
FROM {{ source('raw', 'stock_prices') }} s
WHERE s.ticker IS NOT NULL
  AND s.date IS NOT NULL
  AND s.open IS NOT NULL
  AND s.high IS NOT NULL
  AND s.low IS NOT NULL
  AND s.close IS NOT NULL
  AND s.volume IS NOT NULL
  AND s.open > 0
  AND s.high > 0
  AND s.low > 0
  AND s.close > 0
  AND s.volume >= 0
  AND s.high >= s.low
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY s.ticker, s.date
    ORDER BY s.date DESC
) = 1
 