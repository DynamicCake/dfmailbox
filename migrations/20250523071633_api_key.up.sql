CREATE TABLE api_key (
    id SERIAL PRIMARY KEY,
    plot INTEGER NOT NULL REFERENCES plot(id),
    hashed_key BYTEA NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
