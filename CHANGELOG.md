# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Build-time verification that `libjemalloc` is registered with the dynamic linker (fail fast if the package layout changes)
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
- Lizard gem for RSpec test metric reporting to lizard instance
- Dependabot registry auth for GitHub Packages gem source
- Bake REVISION file into Docker image from GIT_SHA build arg
- `metadata` JSONB column on test_runs for GitHub CI context (run_id, repository)
- OpenAPI 3.1 spec at `public/api/v1/openapi.yaml` with contract tests
- GitHub Pages workflow to publish API spec on push to main
- CI Run link column on project show page
- Pagination on project test runs table via Pagy

### Changed

- Bumped Ruby from 4.0.2 to 4.0.3 (`.ruby-version`, `Gemfile.lock`, Dockerfile `RUBY_VERSION` build arg)
- Run `bin/rails db:prepare` in Dokku `predeploy` instead of `db:migrate` in `postdeploy` so the new release boots against an already-migrated schema (and creates the DB if it does not yet exist)
- Custom DOS bitmap font (Px437_DOS-V_re_ANK24) for site-wide typography
- Combine bootsnap and asset precompile into single Dockerfile RUN layer
- Parallel per-arch Docker builds with manifest merge (replaces QEMU emulation)
- Deploy via Docker registry (build+push in CI) instead of git push to Dokku
- Migrated database from SQLite to PostgreSQL
- Upgraded to Ruby 4.0.0
- Migrated system tests from Selenium to Playwright
- Renamed application from "Test Chronicler" to "Lizard"
- Removed Kamal in favor of Dokku deployment
- Extracted JavaScript into separate modules
- Consolidated authentication to single method
- Refactored vanilla JS (onclick handlers, inline scripts) to Stimulus controllers for API key toggle and metrics chart
- Used full Ruby image for dev Docker stage
- Sign-in page now renders within app layout (removes standalone HTML doc, reuses Simple.css + shared flash handling)
- Capitalized CI job display names and renamed gate job from `ci` to `merge_ready` (Merge Ready)

### Fixed

- Deploy workflow failing when Dokku detects no image changes ("No changes detected, skipping git commit")
- CI gate job passing when dependent jobs fail (`success()` at step level doesn't check `needs` context)
- API key toggle not working (`td code { display: inline-block }` overrode `hidden` attribute)
- Full API key truncated when revealed (scoped `max-width`/`overflow` to truncated element only)
- Auto-select full API key text on reveal for easy copy-paste
- `spec.rake` LoadError during Docker build when rspec unavailable in production
- Stale `bundle_cache` volume blocking `bundle install` (runtime secret + `BUNDLE_USER_CONFIG`)
- Timing attack vulnerability in API key comparison
- Login page layout issues
- Importmap helper availability after `clear_helpers`
- Rake task accumulation bug in web interface
- CI gate job kebab-case job name references
- Project metrics chart not rendering on Turbo Drive navigations (use `turbo:load` instead of `DOMContentLoaded`)
- Project metrics chart not rendering on initial page load (deferred `<script type="module">` missed `turbo:load` event; leaked persistent listener errored on other pages)
- Delete button not working inside Turbo Frame (target `_top` for full-page navigation)
- Delete test run uses Turbo Stream for in-place row removal + flash (replaces `_top` full-page reload)
- Sign-in page not respecting dark mode (hardcoded light colors, no `prefers-color-scheme` media query)
- Failed login rendering sign-in form inside application layout (`layout false` missing `:create` action)
- Playwright browser container silently fetching latest version via `npx` (pin version in `.env`, revert npm bump to match Ruby client)

### Security

- Fixed timing-safe API key comparison
- Added Rack::Attack rate limiting for login and API endpoints
