TRUNCATE TABLE gsc_performance;

COPY gsc_performance(
    date,
    query,
    page,
    clicks,
    impressions,
    ctr,
    position
)
FROM '/data/gsc_real.csv'
DELIMITER ','
CSV HEADER;