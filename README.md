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
```

Lint code:
```bash
bin/standardrb
```

Check Zeitwerk loading:
```bash
bin/rails zeitwerk:check
```
