# Triage Labels

## State labels

| Label | Meaning |
|-------|---------|
| `triage:backlog` | Issue acknowledged, not yet scheduled |
| `triage:in-sprint` | Issue assigned to a milestone/sprint |
| `triage:in-progress` | Work has started (PR linked) |
| `triage:review` | PR open, awaiting review |
| `triage:done` | Closed by merge (usually auto) |

## Category labels

| Label | Meaning |
|-------|---------|
| `type:bug` | Something is broken |
| `type:feature` | New functionality |
| `type:enhancement` | Improvement to existing functionality |
| `type:docs` | Documentation change |
| `type:refactor` | Code restructuring, no behavior change |
| `type:chore` | Maintenance, deps, CI, tooling |
| `type:performance` | Speed or resource optimization |

## Priority labels

| Label | Meaning |
|-------|---------|
| `priority:p0` | Critical — stop everything, fix now |
| `priority:p1` | High — fix this sprint |
| `priority:p2` | Medium — schedule when convenient |
| `priority:p3` | Low — nice to have |

## Usage rules

- Assign **one** state label, **one** category label, and **one** priority label to every new issue.
- State labels are mutually exclusive; category and priority are not.
- When a PR is merged and closes an issue, the state label is removed automatically by GitHub.
- Do not create new labels without checking existing ones first.
