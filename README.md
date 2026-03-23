# Lizard

A simple Rails application for tracking test run metrics across projects.

## Features

- **Project Management**: Create and manage projects with auto-generated API keys
- **Test Run Tracking**: Record test runs via API with metrics tracking
- **Dashboard**: View project overview with recent test runs and metrics
- **Sample Data**: Generate sample data for development and testing

## Getting Started

### Prerequisites

- Ruby 3.x
- Rails 8.x
- PostgreSQL
- Docker and Docker Compose

### Installation

1. Clone the repository
2. Start the server:
   ```bash
   docker compose up app
   ```

Visit `http://localhost:3000` to access the dashboard.

## API

### Create Test Run

```bash
POST /api/v1/test_runs
Authorization: Bearer <project-api-key>
Content-Type: application/json

{
  "test_run": {
    "commit_sha": "abc123",
    "branch": "main",
    "ruby_specs": 100,
    "js_specs": 50,
    "runtime": 30.5,
    "coverage": 85.2,
    "ran_at": "2026-01-01T12:00:00Z",
    "metadata": {
      "github_run_id": "23419710055",
      "github_repository": "djbender/lizard-ruby"
    }
  }
}
```

### API Contract

The full OpenAPI 3.1 spec lives at [`public/api/v1/openapi.yaml`](public/api/v1/openapi.yaml) and is published to [GitHub Pages](https://djbender.github.io/lizard/openapi.yaml) on every push to main.

The spec guarantees:
- **Field names and types** accepted by the API (string, integer, number, date-time)
- **Metadata boundary** — only `github_run_id` and `github_repository` are allowed
- **Response shapes** — `{status, id}` on success, `{error}` on failure
- **Auth scheme** — Bearer token via `Authorization` header
- **All fields inside `test_run` are optional** — the server accepts `{test_run: {}}` with no attributes

A contract test in `spec/contracts/openapi_spec.rb` validates the spec against the actual permitted params, so CI fails if either side drifts. The [lizard-ruby](https://github.com/djbender/lizard-ruby) client gem fetches the published spec and validates its payloads against it.

## Development

Run tests:
```bash
docker compose run --rm app bin/rspec
```

Lint code:
```bash
docker compose run --rm app bin/standardrb
```

Check Zeitwerk loading:
```bash
docker compose run --rm app bin/rails zeitwerk:check
```

Run ./script/install-git-hooks to install Git hooks!

### Playwright Versions

System tests use Playwright. These versions should align when possible:

| Component              | Version | Location           |
|------------------------|---------|--------------------|
| playwright-ruby-client | 1.57.1  | Gemfile            |
| playwright (npm)       | 1.57.0  | package.json       |
| playwright (docker)    | 1.58.0  | docker-compose.yml |

Currently mismatched because gem 1.57.x requires browser revision 1208 which
ships with Playwright 1.58.0. Future releases should align all three.

## Deployment

Deploys automatically via GitHub Actions when CI passes on main. Manual deploys available via workflow dispatch or `git push dokku main`.

### Dokku Server Setup

```bash
dokku apps:create lizard
dokku postgres:create lizard-db
dokku postgres:link lizard-db lizard

dokku config:set lizard SITE_PASSWORD=password
dokku config:set lizard SECRET_KEY_BASE=$(openssl rand -hex 64)
```

### GitHub Secrets Required

| Secret                  | Description                        |
|-------------------------|------------------------------------|
| `DOKKU_HOST`            | Dokku server hostname              |
| `DOKKU_PORT`            | SSH port                           |
| `DOKKU_SSH_PRIVATE_KEY` | SSH private key for `dokku` user   |

### Post-Deploy

Migrations run automatically. Manual run if needed:
```bash
dokku run lizard bin/rails db:migrate
```
