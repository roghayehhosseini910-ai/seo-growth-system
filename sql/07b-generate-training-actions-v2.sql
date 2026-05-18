WITH src AS (
    SELECT
        date,
        page,
        GREATEST(0, clicks + (random()*10)::int - 5) AS clicks,
        GREATEST(1, impressions + (random()*200)::int - 100) AS impressions,
        LEAST(1, GREATEST(0, (ctr + (random()*0.02) - 0.01))) AS ctr,
        LEAST(100, GREATEST(1, (avg_position + (random()*2) - 1))) AS avg_position
    FROM v_gsc_page_daily
    ORDER BY random()
    LIMIT 400
    ),
    labeled AS (
    SELECT
        page,
        MIN(date) OVER () AS sample_date,

    CASE
        WHEN impressions > 60000 AND ctr < 0.10 AND avg_position BETWEEN 10 AND 20
            THEN 'PAGE_CTR_QUICKWIN'
        WHEN avg_position <= 5 AND ctr < 0.08 AND impressions > 20000
            THEN 'SNIPPET_OPTIMIZATION'
        WHEN impressions > 60000 AND avg_position > 20
            THEN 'CONTENT_REFRESH'
        WHEN ctr >= 0.12 AND impressions < 15000
            THEN 'INTERNAL_LINKING_BOOST'
        ELSE 'MONITOR'
    END AS decision_type,

    CASE
        WHEN impressions > 60000 AND ctr < 0.10 AND avg_position BETWEEN 10 AND 20
            THEN 'HIGH_IMPRESSIONS_LOW_CTR_MID_POS'
        WHEN avg_position <= 5 AND ctr < 0.08 AND impressions > 20000
            THEN 'HIGH_POS_LOW_CTR'
        WHEN impressions > 60000 AND avg_position > 20
            THEN 'HIGH_IMPRESSIONS_BAD_POSITION'
        WHEN ctr >= 0.12 AND impressions < 15000
            THEN 'GOOD_CTR_LOW_IMPRESSIONS'
        ELSE 'NO_STRONG_SIGNAL'
    END AS reason_code,

    (
        impressions
        * (1 - ctr)
        * (1 / (1 + avg_position))
        * (0.8 + random()*0.4)
    )::numeric AS priority_score,

    jsonb_build_object(
        'date', MIN(date) OVER (),
        'impressions', impressions,
        'clicks', clicks,
        'ctr', round(ctr::numeric, 4),
        'avg_position', round(avg_position::numeric, 2)
    ) AS metrics,

    CASE
        WHEN impressions > 60000 AND ctr < 0.10 AND avg_position BETWEEN 10 AND 20 THEN
            jsonb_build_array(
            jsonb_build_object('action','rewrite_title','why','Increase CTR'),
            jsonb_build_object('action','rewrite_meta_description','why','Improve snippet relevance'),
            jsonb_build_object('action','add_rich_snippet','why','Improve SERP visibility')
            )
        WHEN avg_position <= 5 AND ctr < 0.08 AND impressions > 20000 THEN
            jsonb_build_array(
            jsonb_build_object('action','rewrite_title','why','Low CTR despite high rank'),
            jsonb_build_object('action','test_snippet_variants','why','A/B snippet ideas')
            )
        WHEN impressions > 60000 AND avg_position > 20 THEN
            jsonb_build_array(
            jsonb_build_object('action','refresh_content','why','Ranking is low with high demand'),
            jsonb_build_object('action','improve_internal_links','why','Boost topical authority')
            )
        WHEN ctr >= 0.12 AND impressions < 15000 THEN
            jsonb_build_array(
            jsonb_build_object('action','add_internal_links','why','Good CTR but low visibility'),
            jsonb_build_object('action','expand_coverage','why','Capture more queries')
            )
        ELSE
            jsonb_build_array(
            jsonb_build_object('action','monitor','why','No strong signal')
            )
        END AS recommended_actions
    FROM src
),
final_rows AS (
    SELECT
        page,
        decision_type,
        reason_code,
        priority_score,
        metrics,
        recommended_actions,
        md5(page || '|' || decision_type || '|' || reason_code || '|' || sample_date::text) AS row_hash FROM labeled)
INSERT INTO actions_log (
    page,
    decision_type,
    reason_code,
    priority_score,
    metrics,
    recommended_actions,
    row_hash
)
SELECT
    page,
    decision_type,
    reason_code,
    priority_score,
    metrics,
    recommended_actions,
    row_hash
FROM final_rows
ON CONFLICT (row_hash) DO NOTHING;
