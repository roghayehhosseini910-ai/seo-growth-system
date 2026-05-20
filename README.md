
````markdown
# SEO Growth System

Production-oriented AI-driven SEO automation and decision intelligence platform built with Python, PostgreSQL, SQL, Docker and machine learning pipelines.

This project was designed as a real-world engineering portfolio system to demonstrate practical skills in:

- data engineering
- automation workflows
- SEO analytics
- decision systems
- machine learning pipelines
- explainability
- KPI evaluation
- Docker-based infrastructure

---

# Project Goal

Modern SEO teams work with large amounts of performance data, but identifying optimization opportunities is often manual, repetitive and difficult to scale.

The goal of this project is to transform raw SEO performance data into:

- structured data pipelines
- automated SEO insights
- prioritized optimization actions
- ML-ready datasets
- explainable decision logic
- KPI-driven evaluation workflows

---

# What the System Does

The platform:

1. Ingests SEO performance data
2. Stores and processes data in PostgreSQL
3. Builds SQL-based reporting and analytics views
4. Generates prioritized SEO recommendations
5. Maintains idempotent action logging
6. Creates ML-ready datasets
7. Trains machine learning models
8. Generates explainability outputs using SHAP
9. Evaluates outcomes and KPI metrics
10. Automates daily workflows using Docker and scripts

---

# Real Data Integration

The system supports real Google Search Console API ingestion.

Using Google OAuth authentication, the pipeline retrieves real SEO performance data and imports it into PostgreSQL for downstream analytics and decision workflows.

Current imported dataset includes:

- 498 real Search Console rows
- page-level SEO metrics
- impressions
- clicks
- CTR
- average position

---

# Tech Stack

- Python
- PostgreSQL
- SQL
- Docker
- Docker Compose
- scikit-learn
- pandas
- SHAP
- Git
- PowerShell

---

# Architecture Overview

```text
Google Search Console API
            ↓
     Raw SEO Data
            ↓
 PostgreSQL Storage
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

---

# Main Components

## Data Layer

The data layer imports SEO performance data into PostgreSQL and creates structured SQL views for analytics and downstream processing.

Main files:

* `sql/01-create-table.sql`
* `sql/02-import-csv.sql`
* `sql/03-create-views.sql`
* `sql/04-indexes.sql`

---

## Decision Engine

The decision engine analyzes SEO metrics such as impressions, CTR and average position to generate prioritized optimization opportunities.

Main files:

* `sql/07-decision-opportunities.sql`
* `sql/07b-generate-training-actions-v2.sql`
* `sql/09-create-actions-log.sql`

The system uses `row_hash` and conflict handling logic to maintain idempotent action logging and avoid duplicate actions during repeated pipeline executions.

---

## Machine Learning Pipeline

The ML pipeline creates training datasets, trains machine learning models and stores prediction artifacts.

Main files:

* `sql/10-ml-training-dataset.sql`
* `sql/11-feature-engineering.sql`
* `ml/train-model.py`

Generated artifacts include:

* trained model
* evaluation metrics
* prediction samples

---

## Explainability Layer

The explainability layer uses SHAP-based outputs to improve transparency and interpretability of model predictions.

Main files:

* `sql/08-explainability.sql`
* `ml/explain-model.py`

---

## Evaluation and KPI Layer

The evaluation layer tracks generated actions, outcomes and KPI-based reporting views.

Main files:

* `sql/12-evaluation.sql`
* `sql/13-create-action-outcomes.sql`
* `sql/14-evaluate-decisions.sql`
* `sql/15-kpi-daily.sql`

Current development note:

`action_outcomes` is currently not populated with production outcome data. Therefore, `v_kpi_daily` currently returns zero rows. This is expected at the current development stage.

---

## Automation Layer

The project includes automation scripts for running and validating the pipeline.

Main files:

* `ops/run_daily.ps1`
* `ops/check_system.ps1`

---

# Current Status

## Completed

* Dockerized PostgreSQL and ML services
* SQL data pipeline
* Real Google Search Console API integration
* Decision engine
* Idempotent action logging
* ML-ready dataset generation
* Model training pipeline
* SHAP explainability outputs
* KPI and evaluation layer
* Automated daily workflow scripts
* Git-based project structure

---

## In Progress

* Outcome learning loop
* FastAPI backend layer
* Dashboard and reporting interface
* VPS deployment and scheduling
* SaaS-oriented architecture expansion

---

# How to Run

## Start Docker services

```powershell
docker compose up -d
```

## Run the daily workflow

```powershell
.\ops\run_daily.ps1
```

## Run system health check

```powershell
.\ops\check_system.ps1
```

---

# Example Health Check Output

Expected current development output:

```text
actions: 22
outcomes: 0
v_kpi_daily: 0 rows
```

This indicates that the decision engine and automation pipeline are functioning correctly, while outcome learning is still under development.

---

# Why This Project Matters

This project demonstrates practical engineering skills relevant to:

* Junior AI Engineer
* AI Automation Engineer
* Technical SEO Engineer
* Junior Data Engineer
* Analytics Engineer

Core demonstrated skills include:

* data pipelines
* SQL engineering
* automation workflows
* machine learning pipelines
* explainability
* KPI evaluation
* Docker-based development
* production-oriented engineering

---

# Author

## Roghayeh Hosseini

Junior AI Engineer | AI Automation | SEO Decision Systems

GitHub:
[https://github.com/roghayehhosseini910-ai/seo-growth-system](https://github.com/roghayehhosseini910-ai/seo-growth-system)

LinkedIn:
[https://www.linkedin.com/in/roghayeh-hosseini-30b33b2a9](https://www.linkedin.com/in/roghayeh-hosseini-30b33b2a9)

```
