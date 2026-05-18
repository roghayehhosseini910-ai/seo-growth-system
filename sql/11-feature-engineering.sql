    -- ============================================================
    -- 11-feature-engineering.sql (FINAL)
    -- Build page-level feature store view for ML
    -- Source: v_gsc_page_daily (date, page, clicks, impressions, ctr, avg_position)
    -- ============================================================

DROP VIEW IF EXISTS v_ml_training_dataset CASCADE;

DROP VIEW IF EXISTS v_gsc_page_features CASCADE;

    CREATE VIEW v_gsc_page_features AS
    SELECT
    date::date AS date,
    page,
    clicks::numeric AS clicks,
    impressions::numeric AS impressions,
    ctr::numeric AS ctr,
    avg_position::numeric AS avg_position,

    -- 7d / 14d lag features
    LAG(ctr, 7)           OVER (PARTITION BY page ORDER BY date) AS ctr_7d_ago,
    LAG(ctr, 14)          OVER (PARTITION BY page ORDER BY date) AS ctr_14d_ago,
    LAG(avg_position, 7)  OVER (PARTITION BY page ORDER BY date) AS pos_7d_ago,
    LAG(impressions, 7)   OVER (PARTITION BY page ORDER BY date) AS impr_7d_ago,
    LAG(clicks, 7)        OVER (PARTITION BY page ORDER BY date) AS clicks_7d_ago,

    -- 7d moving averages (past 7 days including today)
    AVG(ctr)          OVER (PARTITION BY page ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ctr_ma_7d,
    AVG(avg_position) OVER (PARTITION BY page ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS pos_ma_7d,
    AVG(impressions)  OVER (PARTITION BY page ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS impr_ma_7d,
    AVG(clicks)       OVER (PARTITION BY page ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS clicks_ma_7d,

    -- 7d volatility
    STDDEV_SAMP(ctr)          OVER (PARTITION BY page ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ctr_vol_7d,
    STDDEV_SAMP(avg_position) OVER (PARTITION BY page ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS pos_vol_7d

    FROM v_gsc_page_daily;
