-- +goose Up
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  password_hash TEXT NOT NULL, 
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ,

  CONSTRAINT users_email_no_whitespace
    CHECK (email !~ '[[:space:]]'),

  CONSTRAINT users_email_nonempty
    CHECK (length(email) > 0)
);

CREATE UNIQUE INDEX idx_users_email_lower ON users(LOWER(email));

CREATE TABLE athletes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL,
  display_name TEXT,
  vdot REAL,
  threshold_pace_s_km INTEGER,
  max_hr SMALLINT,
  lthr SMALLINT,
  resting_hr SMALLINT,
  weekly_days SMALLINT NOT NULL DEFAULT 3,
  preferred_units TEXT NOT NULL DEFAULT 'km',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  FOREIGN KEY(user_id) REFERENCES users(id)
    ON DELETE CASCADE,

  CONSTRAINT positive_vdot
    CHECK (vdot > 0),

  CONSTRAINT positive_threshold_pace
    CHECK (threshold_pace_s_km > 0),

  CONSTRAINT valid_range_max_hr
    CHECK (max_hr BETWEEN 100 AND 240),

  CONSTRAINT valid_lthr
    CHECK (lthr > 0 AND lthr < max_hr),

  CONSTRAINT valid_resting_hr
    CHECK (resting_hr >= 25 AND resting_hr < max_hr),

  CONSTRAINT valid_weekly_days
    CHECK (weekly_days BETWEEN 3 AND 6),

  CONSTRAINT valid_units
    CHECK (preferred_units IN ('km', 'mi'))
);

CREATE TABLE user_sessions (
  token_hash TEXT PRIMARY KEY,
  user_id UUID NOT NULL,
  athlete_id UUID NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  FOREIGN KEY(user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  
  FOREIGN KEY(athlete_id) REFERENCES athletes(id)
    ON DELETE CASCADE,

  CONSTRAINT valid_expires_at
    CHECK(expires_at > created_at)
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_athlete_id ON user_sessions(athlete_id);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

CREATE TABLE strava_tokens (
  athlete_id UUID PRIMARY KEY REFERENCES athletes(id)
    ON DELETE CASCADE,
  strava_athlete_id BIGINT NOT NULL UNIQUE,
  access_token_enc TEXT NOT NULL,
  refresh_token_enc TEXT NOT NULL,
  scope TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  last_sync_epoch BIGINT CHECK(last_sync_epoch >= 0),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- +goose Down
DROP TABLE IF EXISTS strava_tokens;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS athletes;
DROP TABLE IF EXISTS users;

