\set ON_ERROR_STOP on
\timing on

\echo '========== DAILY RUN START =========='

-- 1) Decision & actions
\echo '-> Decision engine'
\i /sql/07-decision-opportunities.sql
\i /sql/07b-generate-training-actions-v2.sql

-- 2) Explainability & ML prep
\echo '-> Explainability'
\i /sql/08-explainability.sql

\echo '-> ML dataset & features'
\i /sql/11-feature-engineering.sql
\i /sql/10-ml-training-dataset.sql

-- 3) Evaluation
\echo '-> Evaluation'
\i /sql/12-evaluation.sql

-- 4) Reporting (SAFE, READ-ONLY)
\echo '-> Reports (human-readable)'
\i /sql/05-export-daily-report.sql
\i /sql/06-export-top-queries.sql

\echo '========== DAILY RUN DONE =========='
