# scripts/run-ml.ps1
Set-Location (Split-Path $PSScriptRoot -Parent)

docker compose up -d

# DB pipeline
docker compose exec db psql -U seo -d seodb -f /sql/run_daily.sql

# ML pipeline
docker compose exec ml python /app/ml/train-model.py
docker compose exec ml python /app/ml/explain-model.py
docker compose exec ml python /app/ml/decision-engine.py
