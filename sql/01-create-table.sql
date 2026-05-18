DROP TABLE IF EXISTS gsc_performance;

CREATE TABLE gsc_performance (
    date DATE,
    query TEXT,
    page TEXT,
    clicks INTEGER,
    impressions INTEGER,
    ctr REAL,
    position REAL
);
