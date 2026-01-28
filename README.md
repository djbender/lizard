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
- SQLite3

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```

3. Setup the database:
   ```bash
   bin/rails db:create db:migrate
   ```

4. Start the server:
   ```bash
   bin/rails server
   ```

Visit `http://localhost:3000` to access the dashboard.

## API

### Create Test Run

```bash
POST /api/v1/test_runs
Content-Type: application/json

{
  "api_key": "your-project-api-key",
  "test_run": {
    "ran_at": "2024-01-01T12:00:00Z",
    "duration": 120.5,
    "passed": 45,
    "failed": 2,
    "skipped": 1
  }
}
```

## Development

Run tests:
```bash
bin/rspec

# Use SQLite3 instead of PostgreSQL for tests
DATABASE_URL=sqlite3:db/test.sqlite3 bin/rspec
```

Lint code:
```bash
bin/standardrb
```

Check Zeitwerk loading:
```bash
bin/rails zeitwerk:check
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
