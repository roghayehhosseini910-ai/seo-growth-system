-- ============================================================
-- 10-ml-training-dataset.sql (FINAL)
-- Supervised dataset for CTR uplift prediction (Outcome-based)
-- Features: v_gsc_page_features (NO future leakage)
-- Labels: LEAD from v_gsc_page_daily (future outcome)
-- Output CSV: /data/ml_training.csv
-- ============================================================

DROP VIEW IF EXISTS v_ml_training_dataset;

CREATE VIEW v_ml_training_dataset AS
WITH feat AS (
  SELECT
    date,
    page,
    clicks,
    impressions,
    ctr,
    avg_position,

    ctr_7d_ago,
    pos_7d_ago,
    impr_7d_ago,
    clicks_7d_ago,

    ctr_ma_7d,
    pos_ma_7d,
    impr_ma_7d,
    clicks_ma_7d,

    ctr_vol_7d,
    pos_vol_7d
  FROM v_gsc_page_features
),

future AS (
  SELECT
    page,
    date::date AS date,
    LEAD(ctr::numeric, 14)          OVER (PARTITION BY page ORDER BY date) AS ctr_t_plus_14,
    LEAD(avg_position::numeric, 14) OVER (PARTITION BY page ORDER BY date) AS pos_t_plus_14
  FROM v_gsc_page_daily
),

joined AS (
  SELECT
    f.*,
    fu.ctr_t_plus_14,
    fu.pos_t_plus_14,

    -- engineered deltas (all from past/current)
    (f.ctr - f.ctr_7d_ago) AS ctr_delta_7d,
    (f.pos_7d_ago - f.avg_position) AS pos_improve_7d,
    (f.impressions - f.impr_7d_ago) AS impr_delta_7d,
    (f.clicks - f.clicks_7d_ago) AS clicks_delta_7d

  FROM feat f
  JOIN future fu
    ON fu.page = f.page AND fu.date = f.date
)

SELECT
  -- keys
  page, date,

  -- snapshot
  clicks, impressions, ctr, avg_position,

  -- features
  ctr_7d_ago, pos_7d_ago, impr_7d_ago, clicks_7d_ago,
  ctr_delta_7d, pos_improve_7d, impr_delta_7d, clicks_delta_7d,
  ctr_ma_7d, pos_ma_7d, impr_ma_7d, clicks_ma_7d,
  ctr_vol_7d, pos_vol_7d,

  -- future for inspection
  ctr_t_plus_14, pos_t_plus_14,

  -- LABELS
  CASE
    WHEN ctr_t_plus_14 IS NULL THEN NULL
    WHEN ctr IS NULL OR ctr = 0 THEN 0
    WHEN ctr_t_plus_14 >= ctr * 1.05 THEN 1
    ELSE 0
  END AS label_ctr_uplift_14d,

 CASE
    WHEN pos_t_plus_14 IS NULL THEN NULL
    WHEN pos_t_plus_14 <= avg_position - 1.0 THEN 1
    ELSE 0
 END AS label_pos_uplift_14d

FROM joined
WHERE
    joined.ctr_7d_ago IS NOT NULL
    AND joined.pos_7d_ago IS NOT NULL
    AND joined.impr_7d_ago IS NOT NULL
    AND joined.clicks_7d_ago IS NOT NULL
    AND joined.ctr_t_plus_14 IS NOT NULL
    AND joined.pos_t_plus_14 IS NOT NULL
    AND joined.impressions > 0;


\copy (SELECT * FROM v_ml_training_dataset ORDER BY page, date) TO '/data/ml_training.csv' CSV HEADER;
