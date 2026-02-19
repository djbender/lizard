# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- API endpoint for submitting test runs (`POST /api/v1/test_runs`)
- Session-based password authentication with 24h expiry (replaced HTTP basic auth)
- Rate limiting via Rack::Attack to prevent brute-force attacks
- Docker Compose dev environment with web, db, browser, test, and pghero services
- Remote Playwright browser container for system tests
- Video recording on test failure (saved to `tmp/capybara/videos/`)
- CI pipeline with gate job, caching, system tests, and documentation formatter
- Automated Dokku deployment on CI success
- Dependabot for Ruby gems and npm packages with batch rebase/retrigger workflows
- Git hooks for StandardRB (pre-commit autofix, pre-push check)
- Multi-platform Docker builds via buildx bake (AMD64/ARM64)
- Justfile with build/push/deploy/release recipes
- Dashboard with charts for test run metrics
- Project delete functionality
- API key display on project page
- `bin/console` for interactive debugging
- direnv support with GIT_SHA dirty flag

### Changed

- Migrated database from SQLite to PostgreSQL
- Upgraded to Ruby 4.0.0
- Migrated system tests from Selenium to Playwright
- Renamed application from "Test Chronicler" to "Lizard"
- Removed Kamal in favor of Dokku deployment
- Extracted JavaScript into separate modules
- Consolidated authentication to single method
- Used full Ruby image for dev Docker stage

### Fixed

- Timing attack vulnerability in API key comparison
- Login page layout issues
- Importmap helper availability after `clear_helpers`
- Rake task accumulation bug in web interface
- CI gate job kebab-case job name references

### Security

- Fixed timing-safe API key comparison
- Added Rack::Attack rate limiting for login and API endpoints
