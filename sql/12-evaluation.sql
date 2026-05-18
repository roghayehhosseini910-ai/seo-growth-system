-- ============================================================
-- 12-evaluation.sql
-- Decision Evaluation (SQL + Python)
-- Inputs:
--   - v_gsc_page_daily (page, date, ctr, clicks, impressions, avg_position, ...)
--   - Decision summary CSV: /data/decisions/seo_actions_summary.csv
-- Output:
--   - Views for outcomes + evaluation summary
-- ============================================================

-- 1) Store decisions (clean summary, easy to query)
CREATE TABLE IF NOT EXISTS seo_decisions_summary (
    decision_id        BIGSERIAL PRIMARY KEY,
    run_id             TEXT NOT NULL DEFAULT to_char(now(), 'YYYYMMDD_HH24MISS'),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),

    page               TEXT NOT NULL,
    decision_date      DATE NOT NULL,

    prediction_proba   NUMERIC,
    priority           TEXT,

    action_1           TEXT,
    action_2           TEXT,
    action_3           TEXT,

    signal_1_feature   TEXT,
    signal_1_shap      NUMERIC,
    signal_2_feature   TEXT,
    signal_2_shap      NUMERIC,
    signal_3_feature   TEXT,
    signal_3_shap      NUMERIC
);

CREATE INDEX IF NOT EXISTS idx_decisions_page_date
    ON seo_decisions_summary(page, decision_date);

-- 2) Attach outcomes (CTR after 14 days)
CREATE OR REPLACE VIEW v_decisions_with_outcome AS
SELECT
    d.decision_id,
    d.run_id,
    d.created_at,
    d.page,
    d.decision_date,
    d.prediction_proba,
    d.priority,
    d.action_1, d.action_2, d.action_3,
    d.signal_1_feature, d.signal_1_shap,
    d.signal_2_feature, d.signal_2_shap,
    d.signal_3_feature, d.signal_3_shap,

    g0.ctr           AS ctr_t,
    g14.ctr          AS ctr_t_plus_14,

    CASE
        WHEN g0.ctr IS NULL OR g14.ctr IS NULL OR g0.ctr = 0 THEN NULL
        ELSE (g14.ctr - g0.ctr)
    END AS ctr_abs_delta_14d,

    CASE
        WHEN g0.ctr IS NULL OR g14.ctr IS NULL OR g0.ctr = 0 THEN NULL
        ELSE (g14.ctr / g0.ctr) - 1
    END AS ctr_rel_delta_14d,

    CASE
        WHEN g0.ctr IS NULL OR g14.ctr IS NULL OR g0.ctr = 0 THEN NULL
        WHEN g14.ctr >= g0.ctr * 1.05 THEN 1
        ELSE 0
        END AS actual_ctr_uplift_14d

FROM seo_decisions_summary d
LEFT JOIN v_gsc_page_daily g0
    ON g0.page = d.page AND g0.date::date = d.decision_date
LEFT JOIN v_gsc_page_daily g14
    ON g14.page = d.page AND g14.date::date = (d.decision_date + INTERVAL '14 days')::date;

-- 3) Summary by priority
CREATE OR REPLACE VIEW v_eval_by_priority AS
SELECT
    priority,
    COUNT(*) AS n_total,
    COUNT(*) FILTER (WHERE actual_ctr_uplift_14d IS NOT NULL) AS n_labeled,
    AVG(prediction_proba) AS avg_pred_proba,
    AVG(actual_ctr_uplift_14d::numeric) FILTER (WHERE actual_ctr_uplift_14d IS NOT NULL) AS uplift_rate_14d,
    AVG(ctr_rel_delta_14d) FILTER (WHERE ctr_rel_delta_14d IS NOT NULL) AS avg_ctr_rel_delta_14d,
    AVG(ctr_abs_delta_14d) FILTER (WHERE ctr_abs_delta_14d IS NOT NULL) AS avg_ctr_abs_delta_14d
FROM v_decisions_with_outcome
GROUP BY 1
ORDER BY 1;

-- 4) Calibration buckets (optional but great for "product" story)
CREATE OR REPLACE VIEW v_eval_calibration_deciles AS
WITH labeled AS (
    SELECT *
    FROM v_decisions_with_outcome
    WHERE actual_ctr_uplift_14d IS NOT NULL
),
buckets AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY prediction_proba) AS proba_decile
    FROM labeled
)
SELECT
    proba_decile,
    COUNT(*) AS n,
    AVG(prediction_proba) AS avg_pred,
    AVG(actual_ctr_uplift_14d::numeric) AS actual_rate
FROM buckets
GROUP BY 1
ORDER BY 1;
