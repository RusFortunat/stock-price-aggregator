from fastapi import FastAPI

app = FastAPI()


@app.get("/stocks/{ticker}")
def get_stock(ticker: str):
  return {
      "ticker": ticker,
      "message": "Hello from FastAPI"
  }