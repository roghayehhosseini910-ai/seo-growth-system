\copy ( SELECT * FROM v_gsc_daily ORDER BY date ) TO '/data/daily_report.csv' WITH (FORMAT csv, HEADER true);
