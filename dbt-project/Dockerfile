FROM python:3.12-slim

WORKDIR /dbt

RUN pip install --no-cache-dir dbt-athena-community

COPY dbt_project.yml .
COPY models ./models

CMD ["dbt", "--help"]