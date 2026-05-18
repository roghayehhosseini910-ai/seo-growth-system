CREATE INDEX IF NOT EXISTS idx_gsc_date ON gsc_performance(date);
CREATE INDEX IF NOT EXISTS idx_gsc_query ON gsc_performance(query);
CREATE INDEX IF NOT EXISTS idx_gsc_page ON gsc_performance(page);
