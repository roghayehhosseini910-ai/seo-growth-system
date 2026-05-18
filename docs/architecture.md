
````markdown
# Architecture — SEO Growth System

## High-Level Architecture

```text
Synthetic / GSC-like Data
        ↓
PostgreSQL Database
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
ML Model Training
        ↓
SHAP Explainability
        ↓
Outcome Evaluation
        ↓
KPI Reporting
        ↓
Reports / Future API / Future Dashboard
````

## Services

The project uses Docker Compose with two main services:

### Database Service

Technology:

* PostgreSQL

Responsibilities:

* store SEO performance data
* run SQL pipeline
* create views
* store decisions
* store outcomes
* expose KPI views

### ML Service

Technology:

* Python

Responsibilities:

* train model
* generate metrics
* run explainability
* generate decision output files

## Data Flow

### 1. Input Data

Current input:

```text
data/synthetic_gsc.csv
```

This represents Google Search Console-like performance data.

### 2. Raw Storage

Data is imported into PostgreSQL table:

```text
gsc_performance
```

### 3. Reporting Views

SQL views transform raw data into structured reports.

### 4. Feature Engineering

Feature engineering creates ML-ready page-level features.

Main output:

```text
v_gsc_page_features
```

### 5. Decision Engine

The decision engine generates prioritized actions.

Main output:

```text
actions_log
```

Important fields:

* `page`
* `decision_type`
* `reason_code`
* `priority_score`
* `metrics`
* `recommended_actions`
* `row_hash`

### 6. ML Dataset

The system builds a machine learning dataset.

Main output:

```text
v_ml_training_dataset
data/ml_training.csv
```

### 7. Model Training

The ML pipeline trains a model and saves artifacts.

Outputs:

```text
data/artifacts/logistic_model.joblib
data/artifacts/metrics.json
data/artifacts/predictions_sample.csv
```

### 8. Explainability

The explainability pipeline generates feature importance and prediction samples.

Outputs:

```text
data/artifacts/shap_feature_importance.csv
data/artifacts/shap_predictions_sample.csv
```

### 9. KPI Layer

The KPI layer is based on action outcomes.

Main view:

```text
v_kpi_daily
```

Current state:

This view returns 0 rows until outcome data is populated.

## Idempotency

The system uses `row_hash` to prevent duplicate action insertion.

This allows the daily pipeline to be run repeatedly without creating duplicated action records.

## Current Verified State

```text
actions_log = 22
action_outcomes = 0
v_kpi_daily = 0 rows
```

Interpretation:

* Decision generation works.
* Outcome evaluation structure exists.
* KPI view is ready.
* Feedback loop requires outcome data.

````