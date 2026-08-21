import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({});

const BUCKET_NAME = process.env.BUCKET_NAME!;
const ALPHA_VANTAGE_API_KEY = process.env.ALPHA_VANTAGE_API_KEY!;

interface LambdaEvent {
  ticker: string;
}

interface StockPrice {
  ticker: string;
  date: string;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
}

export const handler = async (event: LambdaEvent) => {
  const ticker = event.ticker?.toUpperCase();

  if (!ticker) {
    throw new Error("ticker is required");
  }

  const url =
    `https://www.alphavantage.co/query` +
    `?function=TIME_SERIES_DAILY` +
    `&symbol=${ticker}` +
    `&outputsize=compact` +
    `&apikey=${ALPHA_VANTAGE_API_KEY}`;

  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`Alpha Vantage request failed: ${response.status}`);
  }

  const data = await response.json();

  // we need to remove metadata from the response for Glue Crawler to be able to infer the schema
  const processedData = processStockData(ticker, data)
    .map(r => JSON.stringify(r)).join("\n");

  const ingestionDate = new Date().toISOString().split("T")[0]; // "2026-08-21"
  const key = `raw/stock_prices/ingestion_date=${ingestionDate}/data.json`;
  
  await s3.send(
    new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key,
      Body: JSON.stringify(processedData),
      ContentType: "application/json",
    })
  );

  return {
    statusCode: 200,
    body: JSON.stringify({
      ticker,
      s3Key: key,
    }),
  };
};

function processStockData(
  ticker: string,
  data: any
): StockPrice[] {
  const timeSeries = data["Time Series (Daily)"];

  if (!timeSeries) {
    throw new Error("Time Series (Daily) not found in API response");
  }

  return Object.entries(timeSeries).map(([date, values]: [string, any]) => ({
    ticker,
    date,
    open: Number(values["1. open"]),
    high: Number(values["2. high"]),
    low: Number(values["3. low"]),
    close: Number(values["4. close"]),
    volume: Number(values["5. volume"]),
  }));
}