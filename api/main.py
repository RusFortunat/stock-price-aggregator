import os
from fastapi import FastAPI, HTTPException, Query
from pyathena import connect
from pyathena.cursor import DictCursor

app = FastAPI(
    title="Stock Price Aggregator API",
    description="Serves daily metrics, top movers, and ticker summaries from the dbt marts layer",
    version="0.0.1",
)

def get_connection():
    return connect(
        s3_staging_dir=os.environ["ATHENA_STAGING_DIR"],
        work_group=os.environ["ATHENA_WORKGROUP"],
        schema_name=os.environ["MARTS_DATABASE"],
        region_name=os.environ["AWS_REGION"],
        cursor_class=DictCursor,
    )

def run_query(sql: str, params: tuple = ()):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(sql, params)
        return cursor.fetchall()
    finally:
        conn.close()

@app.get("/tickers/{ticker}/history")
def get_ticker_history(ticker: str, days: int = Query(30, ge=1, le=365)):
    rows = run_query(
        """
        SELECT ticker, price_date, close, volume, daily_return, sma_7d, sma_30d, volatility_30d
        FROM mart_daily_metrics
        WHERE ticker = %s
        ORDER BY price_date DESC
        LIMIT %s
        """,
        (ticker.upper(), days),
    )
    if not rows:
        raise HTTPException(status_code=404, detail=f"No data found for ticker '{ticker}'")
    return rows

@app.get("/movers")
def get_top_movers(date: str = Query(..., description="YYYY-MM-DD"), top: int = Query(10, ge=1, le=100)):
    rows = run_query(
        """
        SELECT ticker, price_date, close, daily_return, gainer_rank, loser_rank
        FROM mart_top_movers
        WHERE price_date = %s AND (gainer_rank <= %s OR loser_rank <= %s)
        ORDER BY gainer_rank
        """,
        (date, top, top),
    )
    return rows

@app.get("/tickers/{ticker}/summary")
def get_ticker_summary(ticker: str):
    rows = run_query(
        "SELECT * FROM mart_ticker_summary WHERE ticker = %s",
        (ticker.upper(),),
    )
    if not rows:
        raise HTTPException(status_code=404, detail=f"No summary found for ticker '{ticker}'")
    return rows[0]

@app.get("/health")
def get_health():
    return {
        "status": "healthy",
        "message": "API is running smoothly"
    }