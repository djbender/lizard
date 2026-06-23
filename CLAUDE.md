# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

Rails 8 app for tracking test run metrics across projects. Projects have auto-generated API keys; test runs submitted via API.

## Commands

All commands run via docker compose:

```bash
# Tests — run all
docker compose run --rm app bin/rspec                    # unit/controller (excludes system tests)
docker compose run --rm test                             # system tests only (default CMD: bin/rspec-all)
docker compose run --rm test bin/rspec-all               # everything (unit + controller + system)

# Tests — rake tasks
docker compose run --rm app bin/rails spec               # unit/controller (reads .rspec, excludes system)
docker compose run --rm test bin/rails spec:system       # system tests only (overrides .rspec exclusion)

# Tests — targeted
docker compose run --rm app bin/rspec spec/models                      # single directory
docker compose run --rm app bin/rspec spec/models/project_spec.rb:10   # single test/line
docker compose run --rm test bin/rspec-all spec/system/projects_spec.rb  # single system spec file

# Notes:
# - .rspec has --tag ~type:system → bin/rspec always skips system tests
# - bin/rspec-all uses .rspec_all (no exclusions) → includes system tests
# - System tests (:js) need the `test` service for the Playwright browser container
# - Non-JS system tests use rack_test driver (fast, no browser needed)
# - `app` service lacks HOSTNAME/browser deps, so :js tests fail there

# Lint
docker compose run --rm app bin/standardrb          # check
docker compose run --rm app bin/standardrb --fix    # autofix

# Other
docker compose run --rm app bin/brakeman --no-pager  # security scan
docker compose run --rm app bin/importmap audit      # JS dependency audit
docker compose run --rm app bin/rails zeitwerk:check # autoload check

# Load tests (k6 — runs natively, not in compose)
k6 run k6/scenarios/smoke.js -e BASE_URL=https://lizard.dokku.djbender.com -e SITE_PASSWORD=...
# Scenarios: smoke (sanity), load (typical), stress (find limits), spike (burst).
# See k6/README.md for env vars + structure.
```

## Docker

- Services: `app`, `db`, `browser`, `test`, `pghero`, `prometheus`
- Bundle cache in `bundle_cache` volume
- System tests use remote Playwright browser container
- Profiles: `test` (browser, test), `monitoring` (pghero, prometheus)

```bash
docker compose up -d                          # db + app only
docker compose --profile test up -d           # + browser + test
docker compose --profile monitoring up -d     # + pghero + prometheus
```

### Stale gem warnings ("missing extensions")

```bash
docker compose run --rm app bundle clean --force
```

Removes gems not in current Gemfile.lock. Use `bundle pristine` to recompile native extensions instead.

## Architecture

**Models**: `Project` has_many `TestRun`. Projects auto-generate 64-char hex API key on create.

**Auth**: Site-wide password auth via `SITE_PASSWORD` env var. API endpoints (`/api/`) bypass auth. Sessions expire after 24h.

**API**: `POST /api/v1/test_runs` with `api_key` + test run data (ran_at, duration, passed, failed, skipped).

**Testing**: Capybara + Playwright for system tests. `js: true` metadata triggers Playwright driver. Videos saved on failure to `tmp/capybara/videos/`.

## Monitoring

`/metrics` endpoint exposes Prometheus metrics (yabeda). Bypasses site auth. See `../prometheus/prometheus-dokku-setup.md` for production deployment.

## Git Hooks

Run `./script/install-git-hooks` to install pre-commit (standardrb --fix) and pre-push (standardrb check) hooks.

## Agents

This repo has engineering agent support files in `docs/agents/`:

- `docs/agents/issue-tracker.md` — GitHub issue tracker config (repo: `djbender/lizard`)
- `docs/agents/triage-labels.md` — label vocabulary for issue triage
- `docs/agents/domain.md` — domain model: Project, TestRun, API, auth, metrics

These files are read by engineering skills (triage, to-issues, to-prd, review, implement, etc.) to understand the project's issue tracking workflow and domain language. Do not edit them manually unless switching issue trackers or restarting setup.
