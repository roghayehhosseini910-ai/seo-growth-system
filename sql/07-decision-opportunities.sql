INSERT INTO actions_log (
    created_at,
    page,
    decision_type,
    reason_code,
    priority_score,
    metrics,
    recommended_actions,
    row_hash
)
SELECT
    NOW(),
    page,
    'PAGE_CTR_QUICKWIN',
    'HIGH_IMPRESSIONS_LOW_CTR',
    SUM(impressions) * (1 - AVG(ctr)) AS priority_score,
    jsonb_build_object(
        'total_impressions', SUM(impressions),
        'avg_ctr', AVG(ctr),
        'avg_position', AVG(avg_position)
    ) AS metrics,
    jsonb_build_array(
        'Rewrite title and meta description',
        'Improve SERP snippet for CTR',
        'Align content with dominant search intent'
    ) AS recommended_actions,
    md5(
        coalesce(page, '') || '|' ||
        coalesce('PAGE_CTR_QUICKWIN', '') || '|' ||
        coalesce('HIGH_IMPRESSIONS_LOW_CTR', '')
    ) AS row_hash
FROM v_gsc_page_daily
GROUP BY page
HAVING SUM(impressions) > 60000
ON CONFLICT (row_hash) DO NOTHING;
