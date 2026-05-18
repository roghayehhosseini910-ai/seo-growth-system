\set ON_ERROR_STOP on
\timing on

\echo '== BOOTSTRAP START =='

\i /sql/01-create-table.sql
\i /sql/02-import-csv.sql
\i /sql/03-create-views.sql
\i /sql/04-indexes.sql

-- infra tables needed by later steps
\i /sql/09-create-actions-log.sql

\echo '== BOOTSTRAP DONE =='
