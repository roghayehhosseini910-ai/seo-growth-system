CREATE OR REPLACE VIEW v_kpi_daily AS
SELECT
    date_trunc('day', evaluated_at) AS day,
    COUNT(*) AS total_actions,
    COUNT(*) FILTER (WHERE success) AS successful_actions,
    ROUND(AVG(ctr_delta), 4) AS avg_ctr_uplift,
    ROUND(
        COUNT(*) FILTER (WHERE success)::numeric / NULLIF(COUNT(*),0),
        2
    ) AS success_rate
FROM action_outcomes
GROUP BY 1
ORDER BY 1 DESC;
