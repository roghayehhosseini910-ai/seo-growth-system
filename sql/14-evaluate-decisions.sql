WITH candidates AS (
    SELECT
        a.action_id,
        a.row_hash,
        a.page,
        a.created_at,
        a.metrics->>'avg_ctr' AS baseline_ctr,
        a.metrics->>'avg_position' AS baseline_position
    FROM actions_log a
    WHERE a.created_at <= now() - interval '7 days'
),
current_metrics AS (
    SELECT
        page,
        AVG(ctr) AS new_ctr,
        AVG(avg_position) AS new_position
    FROM v_gsc_page_daily
    WHERE date >= now()::date - interval '7 days'
    GROUP BY page
)
INSERT INTO action_outcomes (
    action_id,
    row_hash,
    baseline_ctr,
    baseline_position,
    new_ctr,
    new_position,
    ctr_delta,
    position_delta,
    success,
    evaluation_window_days
)
SELECT
    c.action_id,
    c.row_hash,
    c.baseline_ctr::numeric,
    c.baseline_position::numeric,
    m.new_ctr,
    m.new_position,
    (m.new_ctr - c.baseline_ctr::numeric),
    (c.baseline_position::numeric - m.new_position),
    (m.new_ctr > c.baseline_ctr::numeric),
    7
FROM candidates c
JOIN current_metrics m USING (page)
ON CONFLICT (row_hash, evaluation_window_days) DO NOTHING;
