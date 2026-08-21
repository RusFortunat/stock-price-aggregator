resource "aws_glue_catalog_table" "stock_prices_raw" {
  name          = "stock_prices" # <- stable name dbt will use: source('raw', 'stock_prices')
  database_name = aws_glue_catalog_database.raw.name
  table_type    = "EXTERNAL_TABLE"

  // TODO: since the data will be stored in the Hive format, i am not sure
  // whether I should let crawler update the partition, or do it with Athena 
  // as a part of the workflow
  parameters = {
    "classification"   = "json"
    "typeOfData"        = "file"
    # Lets a crawler UPDATE this table's partitions without renaming it
    "CrawlerSchemaDeserializerVersion" = "1.0"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.bucket}/raw/stock_prices/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "ticker"
      type = "string"
    }
    columns {
      name = "date"
      type = "string"
    }
    columns {
      name = "open"
      type = "double"
    }
    columns {
      name = "high"
      type = "double"
    }
    columns {
      name = "low"
      type = "double"
    }
    columns {
      name = "close"
      type = "double"
    }
    columns {
      name = "volume"
      type = "bigint"
    }
  }

  partition_keys {
    # s3://.../raw/stock_prices/ingestion_date=2026-08-21/
    name = "ingestion_date" 
    type = "string"
  }
}
