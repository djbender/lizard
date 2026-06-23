# Issue Tracker: GitHub

## Type

GitHub repository issues.

## Location

- Repository: `djbender/lizard`
- Remote: `origin` → `git@github.com:djbender/lizard.git`
- Also proxied via `dokku` → `dokku@djbender.com:lizard` (deploy target, not issue tracker)

## How agents should interact

Agents use the `github_*` tools to interact with the GitHub issue tracker:

- `github_search_issues` / `github_list_issues` — find existing issues
- `github_issue_write` — create new issues or update existing ones
- `github_get_file_contents` — read this file and triage-labels.md
- `github_list_labels` / `github_get_label` — read/write labels

## Issue structure

Issues use labels for triage state and category (see `triage-labels.md`).
Labels are defined in the repository at `.github/labels.yml` or created via the GitHub UI — agents should check existing labels before creating new ones.

## Ticket workflow

1. **Backlog** — issue created, unassigned, no milestone
2. **In Sprint** — assigned to a milestone, has an assignee
3. **In Progress** — PR opened referencing the issue (`#issue_number`)
4. **Review** — PR open, awaiting review
5. **Done** — PR merged, issue auto-closed

Agents creating issues should start them at **Backlog** (no milestone, no assignee).
