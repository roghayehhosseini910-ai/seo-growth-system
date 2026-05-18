Write-Host "===== SEO Growth System | DAILY RUN START ====="

docker compose up -d

Write-Host "`n--- Running DB daily pipeline ---"
docker compose exec db psql -U seo -d seodb -f /sql/run-daily.sql

Write-Host "`n--- Training ML model ---"
docker compose exec ml python /app/ml/train-model.py

Write-Host "`n--- Running explainability ---"
docker compose exec ml python /app/ml/explain-model.py

Write-Host "`n--- Running ML decision engine ---"
docker compose exec ml python /app/ml/decision-engine.py

Write-Host "`n===== SEO Growth System | DAILY RUN DONE ====="