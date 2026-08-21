FROM python:3.12-slim

WORKDIR /dbt

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV DBT_PROFILES_DIR=/dbt

# Airflow's EcsRunTaskOperator can override this (e.g. --select, --full-refresh),
# but the image is runnable standalone with this default too.
CMD ["dbt", "run", "--target", "prod"]