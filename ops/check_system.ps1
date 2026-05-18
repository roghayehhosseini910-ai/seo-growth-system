Write-Host "===== SEO Growth System | HEALTH CHECK ====="

Write-Host "`n--- Docker containers ---"
docker ps

Write-Host "`n--- Actions count ---"
docker compose exec db psql -U seo -d seodb -c "SELECT COUNT(*) AS actions FROM actions_log;"

Write-Host "`n--- Outcomes count ---"
docker compose exec db psql -U seo -d seodb -c "SELECT COUNT(*) AS outcomes FROM action_outcomes;"

Write-Host "`n--- KPI preview ---"
docker compose exec db psql -U seo -d seodb -c "SELECT * FROM v_kpi_daily LIMIT 5;"

Write-Host "`n===== HEALTH CHECK DONE ====="