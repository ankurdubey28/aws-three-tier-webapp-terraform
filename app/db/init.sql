CREATE TABLE IF NOT EXISTS feedback (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT feedback_name_not_blank CHECK (length(trim(name)) > 0),
  CONSTRAINT feedback_email_not_blank CHECK (length(trim(email)) > 0),
  CONSTRAINT feedback_message_not_blank CHECK (length(trim(message)) > 0)
);

CREATE INDEX IF NOT EXISTS idx_feedback_created_at
  ON feedback (created_at DESC);
