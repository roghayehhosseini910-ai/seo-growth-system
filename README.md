
````markdown
# SEO Growth System

An end-to-end AI-oriented SEO automation and decision intelligence system built with Python, SQL, PostgreSQL, Docker and ML pipelines.

This project was developed as a production-oriented portfolio project to demonstrate practical skills in data engineering, automation, decision systems, machine learning workflows, explainability and KPI-based evaluation.

## Project Goal

SEO teams often work with large amounts of search performance data, but identifying the right optimization actions is still often manual and time-consuming.

The goal of this project is to transform SEO performance data into:

- structured data pipelines
- explainable decision logic
- prioritized SEO actions
- ML-ready training datasets
- KPI-based evaluation
- automated daily workflows

## What the System Does

The system:

1. Ingests SEO performance data
2. Stores and processes the data in PostgreSQL
3. Builds SQL views for reporting and feature engineering
4. Generates prioritized SEO actions
5. Stores actions in an idempotent action log
6. Creates ML-ready datasets
7. Trains a machine learning model
8. Generates explainability outputs using SHAP
9. Evaluates outcomes and KPI views
10. Runs the full workflow using Docker and automation scripts

## Tech Stack

- Python
- PostgreSQL
- SQL
- Docker
- Docker Compose
- pandas
- scikit-learn
- SHAP
- PowerShell
- Git

## Architecture Overview

SEO Data
   ↓
PostgreSQL Raw Table
   ↓
SQL Views
   ↓
Feature Engineering
   ↓
Decision Engine
   ↓
actions_log
   ↓
ML Training Dataset
   ↓
Model Training
   ↓
Explainability
   ↓
Outcome Evaluation
   ↓
KPI Reporting
````

## Main Components

### Data Layer

The data layer imports SEO performance data into PostgreSQL and builds structured SQL views for later processing.

Main files:

* `sql/01-create-table.sql`
* `sql/02-import-csv.sql`
* `sql/03-create-views.sql`
* `sql/04-indexes.sql`

### Decision Engine

The decision engine generates prioritized SEO actions based on page-level metrics such as impressions, CTR and average position.

Main files:

* `sql/07-decision-opportunities.sql`
* `sql/07b-generate-training-actions-v2.sql`
* `sql/09-create-actions-log.sql`

The system uses `row_hash` and conflict handling to avoid duplicate actions during repeated pipeline runs.

### Machine Learning Pipeline

The ML pipeline creates training data, trains a model and stores model outputs.

Main files:

* `sql/10-ml-training-dataset.sql`
* `sql/11-feature-engineering.sql`
* `ml/train-model.py`

Generated artifacts include:

* model file
* metrics
* prediction samples

### Explainability

The explainability layer uses SHAP-style outputs to make model behavior more transparent.

Main files:

* `sql/08-explainability.sql`
* `ml/explain-model.py`

### Evaluation and KPI Layer

The evaluation layer tracks actions, outcomes and daily KPI views.

Main files:

* `sql/12-evaluation.sql`
* `sql/13-create-action-outcomes.sql`
* `sql/14-evaluate-decisions.sql`
* `sql/15-kpi-daily.sql`

Current note:

`action_outcomes` is currently empty because real outcome data is not yet populated. Therefore, `v_kpi_daily` currently returns zero rows. This is expected at the current development stage.

### Automation

The project includes PowerShell scripts to run and check the system.

Main files:

* `ops/run_daily.ps1`
* `ops/check_system.ps1`

## Current Status

Completed:

* Dockerized PostgreSQL and ML services
* SQL data pipeline
* Decision engine
* Idempotent action logging
* ML-ready dataset generation
* Model training
* Explainability output generation
* KPI and outcome table structure
* Daily run script
* Health check script
* Git-based project structure

In progress:

* Real Google Search Console API ingestion
* Outcome generation and learning loop
* FastAPI layer
* Dashboard or reporting interface
* VPS-based scheduling

## How to Run

Start Docker services:

```powershell
docker compose up -d

Run the full daily pipeline:

.\ops\run_daily.ps1

Check system health:

.\ops\check_system.ps1

## Example Health Check Output

Expected current development output:

actions: 22
outcomes: 0
v_kpi_daily: 0 rows

This means the decision engine is working, but outcomes are not populated yet.

## Why This Project Matters

This project demonstrates practical engineering skills relevant to Junior AI Engineer and AI Automation roles:

* data pipelines
* SQL engineering
* automation
* ML pipeline design
* explainability
* KPI evaluation
* Docker-based development
* production-oriented thinking

## Author

Roghayeh Hosseini
Junior AI Engineer | AI Automation | SEO Decision Systems

````