CREATE TABLE IF NOT EXISTS actions_log (
    action_id SERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now(),

    page TEXT NOT NULL,
    decision_type TEXT NOT NULL,
    reason_code TEXT NOT NULL,

    priority_score NUMERIC NOT NULL,

    metrics JSONB NOT NULL,
    recommended_actions JSONB NOT NULL,

    row_hash TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_actions_log_row_hash
ON actions_log(row_hash);
