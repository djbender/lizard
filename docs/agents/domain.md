# Domain: Lizard — Test Run Metrics Tracker

## What it is

Lizard is a Rails 8 application that tracks test run metrics across projects.
Projects submit test run data via a public API; Lizard stores and exposes
metrics for monitoring and analysis.

## Core concepts

### Project

A registered consumer of the API. Each project gets a 64-character hex API key
on creation. Projects have a name and a list of test runs.

**Model**: `Project`
- `id` — primary key
- `name` — human identifier
- `api_key` — 64-char hex string, auto-generated, unique
- `created_at`, `updated_at`

**Model**: `TestRun`
- `id` — primary key
- `project_id` — foreign key to Project
- `ran_at` — timestamp of when the test run occurred
- `duration` — total duration in seconds
- `passed` — integer count of passed tests
- `failed` — integer count of failed tests
- `skipped` — integer count of skipped tests
- `created_at`, `updated_at`

### Test Run

A single execution of a project's test suite. Submitted via `POST /api/v1/test_runs`
with `api_key` and test run data.

### API

Public endpoints under `/api/` bypass site auth.

- `POST /api/v1/test_runs` — submit a test run (requires `api_key`)

### Auth

Site-wide password auth via `SITE_PASSWORD` environment variable. All non-API
routes require login. Sessions expire after 24 hours.

### Metrics

`/metrics` endpoint exposes Prometheus metrics via Yabeda. Bypasses site auth.
Used by Prometheus for monitoring.

## Architecture notes

- Rails 8 application
- Docker Compose for development: `app`, `db`, `browser`, `test`, `pghero`, `prometheus`
- PostgreSQL database
- Importmap for JS
- StandardRB for linting
- RSpec for testing (unit + system with Playwright)

## API Contract

`POST /api/v1/test_runs`

**Request body:**
```json
{
  "api_key": "string (required)",
  "test_run": {
    "ran_at": "ISO 8601 timestamp (required)",
    "duration": "float (required)",
    "passed": "integer (default: 0)",
    "failed": "integer (default: 0)",
    "skipped": "integer (default: 0)"
  }
}
```

**Response:** `201 Created` with the created TestRun JSON, or `401/422` on error.

## Key files

- `app/models/project.rb` — Project model
- `app/models/test_run.rb` — TestRun model
- `app/controllers/api/v1/test_runs_controller.rb` — API endpoint
- `config/routes.rb` — route definitions
- `Gemfile` — dependencies
