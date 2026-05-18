
# RUNBOOK — SEO Growth System

This runbook explains how to start, run, check and troubleshoot the SEO Growth System.

## 1. Start the Project

Make sure Docker Desktop is running.

From the project root:

```powershell
docker compose up -d
````

Expected result:

```text
Container seo-growth-system-db-1 started
Container seo-growth-system-ml-1 started

Check containers:

docker ps

Expected containers:

* PostgreSQL container
* ML container

## 2. Run Daily Pipeline

Use the operational script:

.\ops\run_daily.ps1

This script runs:

1. Docker services
2. SQL daily pipeline
3. ML training
4. Explainability
5. ML decision engine

Expected output:

SEO Growth System | DAILY RUN DONE

## 3. Check System Health

Run:

.\ops\check_system.ps1

This checks:

* Docker containers
* actions count
* outcomes count
* KPI preview

Expected current development output:

actions: 22
outcomes: 0
v_kpi_daily: 0 rows

## 4. Run SQL Pipeline Manually

docker compose exec db psql -U seo -d seodb -f /sql/run-daily.sql

## 5. Run ML Scripts Manually

Train model:

docker compose exec ml python /app/ml/train-model.py

Run explainability:

docker compose exec ml python /app/ml/explain-model.py

Run decision engine:

docker compose exec ml python /app/ml/decision-engine.py

## 6. Useful SQL Checks

Check actions:

docker compose exec db psql -U seo -d seodb -c "SELECT COUNT(*) AS actions FROM actions_log;"

Check outcomes:

docker compose exec db psql -U seo -d seodb -c "SELECT COUNT(*) AS outcomes FROM action_outcomes;"

Check KPI:

docker compose exec db psql -U seo -d seodb -c "SELECT * FROM v_kpi_daily LIMIT 5;"

List tables:

docker compose exec db psql -U seo -d seodb -c "\dt"

List views:

docker compose exec db psql -U seo -d seodb -c "\dv"

## 7. Known Current Behavior

### actions_log = 22

This means the decision engine is working and generated actions are stored.

### action_outcomes = 0

This is expected because outcome data is not yet populated.

### v_kpi_daily = 0 rows

This is expected until action_outcomes contains outcome records.

## 8. Common Errors

### Error: PowerShell does not recognize SQL command

Wrong:

SELECT COUNT(*) FROM actions_log;

Correct:

docker compose exec db psql -U seo -d seodb -c "SELECT COUNT(*) FROM actions_log;"

### Error: Cannot drop view because other objects depend on it

Cause:

A dependent view exists.

Solution:

Drop dependent views first or use a safe dependency order.

Example:

DROP VIEW IF EXISTS v_ml_training_dataset CASCADE;
DROP VIEW IF EXISTS v_gsc_page_features CASCADE;

## 9. Git Workflow

Check status:

git status

Add changes:

git add .

Commit changes:

git commit -m "Add project documentation and runbook"

## 10. Project Development Roadmap

Next steps:

1. Add outcome simulation or outcome collector
2. Add FastAPI API layer
3. Add dashboard or reporting interface
4. Add tests
5. Improve GitHub showcase
6. Prepare technical interview explanation

## 11. Production Roadmap

Later production steps:

* real Google Search Console API ingestion
* VPS deployment
* scheduled daily runs
* logging
* monitoring
* backup strategy
* authentication
* dashboard

````

---