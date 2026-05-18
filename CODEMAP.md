# CODEMAP — SEO Growth System

This document describes the structure, purpose and execution flow of the SEO Growth System project.

## Root Structure

```text
seo-growth-system/
├── .scripts/
├── data/
├── docs/
├── ml/
├── ops/
├── sql/
├── tests/
├── docker-compose.yaml
├── requirements.txt
├── README.md
├── CODEMAP.md
├── RUNBOOK.md
├── .gitignore
└── .dockerignore
````

## `.scripts/`

Utility scripts used for data generation and reporting.

### `analytics-report.py`

Purpose:

* Generates analytics-style reports from processed data.
* Used for local reporting and development support.

### `generate-synthetic-gsc.py`

Purpose:

* Generates synthetic Google Search Console-like data.
* Used for development before real GSC API integration.

### `run-ml.ps1`

Purpose:

* Runs ML-related scripts from PowerShell.
* Early automation helper for model training and explanation.

## `data/`

Stores generated data, reports, ML artifacts and decision outputs.

Important note:

Most generated data should not be committed to GitHub. These files are ignored by `.gitignore`.

### `data/synthetic_gsc.csv`

Purpose:

* Synthetic SEO performance dataset.
* Used as current input data source.

### `data/daily_report.csv`

Purpose:

* Exported daily report from SQL pipeline.

### `data/top_queries.csv`

Purpose:

* Exported top query report.

### `data/ml_training.csv`

Purpose:

* ML-ready training dataset exported from PostgreSQL.

### `data/artifacts/`

Stores ML artifacts.

Files:

* `logistic_model.joblib`
* `metrics.json`
* `predictions_sample.csv`
* `shap_feature_importance.csv`
* `shap_predictions_sample.csv`

Purpose:

* Stores trained model, metrics and explainability outputs.

### `data/decisions/`

Stores decision engine outputs.

Files:

* `seo_actions.csv`
* `seo_actions_summary.csv`
* `seo_actions_details.jsonl`

Purpose:

* Stores generated SEO actions and summaries.

## `docs/`

Documentation folder for professional project presentation.

### `docs/project-overview.md`

Purpose:

* Explains the business and engineering goal of the project.

### `docs/architecture.md`

Purpose:

* Explains the technical architecture and data flow.

### `docs/github-showcase-notes.md`

Purpose:

* Defines what can be shown publicly and what should remain private.

## `ml/`

Machine learning and decision-related Python scripts.

### `ml/train-model.py`

Purpose:

* Loads ML training data.
* Trains a machine learning model.
* Saves model and metrics to `data/artifacts/`.

Outputs:

* `logistic_model.joblib`
* `metrics.json`
* `predictions_sample.csv`

### `ml/explain-model.py`

Purpose:

* Loads trained model and sample predictions.
* Generates explainability outputs.
* Saves SHAP-style feature importance and prediction explanation samples.

Outputs:

* `shap_feature_importance.csv`
* `shap_predictions_sample.csv`

### `ml/decision-engine.py`

Purpose:

* Reads model or decision outputs.
* Generates SEO action summaries and detailed recommendations.

Outputs:

* `seo_actions_summary.csv`
* `seo_actions_details.jsonl`

### `ml/dockerfile`

Purpose:


* Defines the ML container environment.

## `ops/`

Operational scripts for running and checking the system.

### `ops/run_daily.ps1`

Purpose:

Runs the full daily pipeline:

1. Starts Docker containers
2. Runs DB daily SQL pipeline
3. Trains ML model
4. Runs explainability
5. Runs ML decision engine

### `ops/check_system.ps1`

Purpose:

Checks system health:

* Docker containers
* action count
* outcome count
* KPI preview

## `sql/`

SQL pipeline folder.

### `01-create-table.sql`

Purpose:

* Creates base table for SEO performance data.

Main output:

* `gsc_performance`

### `02-import-csv.sql`

Purpose:

* Imports synthetic GSC CSV data into PostgreSQL.

Input:

* `/data/synthetic_gsc.csv`

Output:

* populated `gsc_performance`

### `03-create-views.sql`

Purpose:

* Creates base reporting views.

Expected views:

* page-level daily metrics
* query-level reporting views

### `04-indexes.sql`

Purpose:

* Creates indexes for performance and query optimization.

### `05-export-daily-report.sql`

Purpose:

* Exports daily report to CSV.

Output:

* `/data/daily_report.csv`

### `06-export-top-queries.sql`

Purpose:

* Exports top query report to CSV.

Output:

* `/data/top_queries.csv`

### `07-decision-opportunities.sql`

Purpose:

* Generates SEO decision opportunities.
* Inserts action candidates into `actions_log`.

Key concepts:

* `decision_type`
* `reason_code`
* `priority_score`
* `metrics`
* `recommended_actions`
* `row_hash`
* `ON CONFLICT DO NOTHING`

### `07b-generate-training-actions-v2.sql`

Purpose:

* Generates training-style action records.
* Used for ML dataset preparation and experimentation.

### `08-explainability.sql`

Purpose:

* Creates explainability-oriented SQL outputs or views.

### `09-create-actions-log.sql`

Purpose:

* Creates `actions_log` table.
* Adds row hash uniqueness for idempotent execution.

Main output:

* `actions_log`

### `10-ml-training-dataset.sql`

Purpose:

* Creates ML training dataset view.
* Exports ML training data to CSV.

Main output:

* `v_ml_training_dataset`
* `/data/ml_training.csv`

### `11-feature-engineering.sql`

Purpose:

* Creates feature engineering views.
* Builds ML-ready features from SEO performance data.

Main output:

* `v_gsc_page_features`

Important note:

This file must respect SQL view dependencies. Dependent views should be dropped before parent views when recreating views.

### `12-evaluation.sql`

Purpose:

* Creates evaluation structures.
* Builds views for evaluating generated decisions.

### `13-create-action-outcomes.sql`

Purpose:

* Creates `action_outcomes` table.

Main output:

* `action_outcomes`

Current state:

* `action_outcomes` currently has 0 rows because outcome population is not implemented yet.

### `14-evaluate-decisions.sql`

Purpose:

* Evaluates generated actions against outcomes.

### `15-kpi-daily.sql`

Purpose:

* Creates daily KPI view.

Main output:

* `v_kpi_daily`

Current state:

* Returns 0 rows until `action_outcomes` is populated.

### `run-bootstrap.sql`

Purpose:

* Initializes database structure.
* Used for first-time setup.

### `run-daily.sql`

Purpose:

* Runs the daily SQL pipeline.
* Main daily database execution script.

## `tests/`

Testing folder.

Current state:

* Contains documentation for planned tests.
* Automated tests will be added later.

## `docker-compose.yaml`

Purpose:

Defines multi-container architecture:

* PostgreSQL database service
* ML service

Key responsibilities:

* database runtime
* ML runtime
* volume mapping
* reproducible local execution

## `requirements.txt`

Purpose:

Defines Python dependencies for ML and data processing.

## Current Verified System State

The system currently runs successfully.

Latest known health check:

```text
actions_log: 22
action_outcomes: 0
v_kpi_daily: 0 rows
Interpretation:

* Decision engine works.
* Actions are being generated.
* Outcomes are not populated yet.
* KPI view is ready but waiting for outcome data.

## Next Engineering Steps
1. Improve documentation
2. Add outcome simulation or outcome collector
3. Add FastAPI service
4. Add tests
5. Create GitHub showcase
6. Prepare interview explanation

````