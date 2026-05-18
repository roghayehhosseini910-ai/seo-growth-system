CREATE OR REPLACE VIEW v_gsc_daily AS
SELECT
    date,
    SUM(clicks) AS clicks,
    SUM(impressions) AS impressions,
    ROUND(SUM(clicks)::numeric / NULLIF(SUM(impressions),0), 4) AS ctr,
    ROUND(AVG(position)::numeric, 2) AS avg_position
FROM gsc_performance
GROUP BY date
ORDER BY date;
CREATE OR REPLACE VIEW v_gsc_query_daily AS
SELECT
    date,
    query,
    SUM(clicks) AS clicks,
    SUM(impressions) AS impressions,
    ROUND((SUM(clicks)::numeric / NULLIF(SUM(impressions),0)), 4) AS ctr,
    ROUND(AVG(position)::numeric, 2) AS avg_position
FROM gsc_performance
GROUP BY date, query
ORDER BY date, clicks DESC;
CREATE OR REPLACE VIEW v_gsc_page_daily AS
SELECT
    date,
    page,
    SUM(clicks) AS clicks,
    SUM(impressions) AS impressions,
    ROUND((SUM(clicks)::numeric / NULLIF(SUM(impressions),0)), 4) AS ctr,
    ROUND(AVG(position)::numeric, 2) AS avg_position
FROM gsc_performance
GROUP BY date, page
ORDER BY date, clicks DESC;
