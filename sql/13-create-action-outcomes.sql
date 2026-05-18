CREATE TABLE IF NOT EXISTS action_outcomes (
    outcome_id SERIAL PRIMARY KEY,

    action_id INT NOT NULL,
    row_hash TEXT NOT NULL,

    evaluated_at TIMESTAMPTZ DEFAULT now(),

    baseline_ctr NUMERIC,
    baseline_position NUMERIC,

    new_ctr NUMERIC,
    new_position NUMERIC,

    ctr_delta NUMERIC,
    position_delta NUMERIC,

    success BOOLEAN,

    evaluation_window_days INT NOT NULL,

    CONSTRAINT fk_action
        FOREIGN KEY (action_id)
        REFERENCES actions_log(action_id)
        ON DELETE CASCADE,

    CONSTRAINT ux_action_outcome UNIQUE (row_hash, evaluation_window_days)
);
