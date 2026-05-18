
```markdown
# Tests — SEO Growth System

This folder will contain automated tests for the SEO Growth System.

## Current Status

Automated tests are not implemented yet.

The system is currently validated through:

- manual pipeline execution
- Docker health checks
- SQL count checks
- ML training output
- explainability output
- decision engine output

## Planned Tests

### Database Tests

Planned checks:

- base table exists
- required views exist
- `actions_log` exists
- `action_outcomes` exists
- `v_kpi_daily` exists

### Pipeline Tests

Planned checks:

- daily pipeline runs without error
- actions are generated
- duplicate actions are prevented
- ML dataset is exported
- reports are generated

### ML Tests

Planned checks:

- training file exists
- model artifact is created
- metrics file is created
- prediction sample is created
- explainability files are created

### Decision Engine Tests

Planned checks:

- decision output files are created
- summary CSV exists
- details JSONL exists
- required columns exist

### Future Test Tools

Potential tools:

- pytest
- SQL validation scripts
- Docker-based test runs
- CI checks with GitHub Actions

## Current Manual Health Check

Run:

```powershell
.\ops\check_system.ps1
````

Expected current output:

```text
actions: 22
outcomes: 0
v_kpi_daily: 0 rows
```

````