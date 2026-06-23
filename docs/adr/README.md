# ADRs: Lizard

## Layout

Architecture Decision Records go in this directory. Each ADR is a separate markdown file.

### Naming convention

`NNNN-title-with-hyphens.md`

Where `NNNN` is a zero-padded sequential number (0001, 0002, ...).

### Template

```markdown
# NNNN: Title

## Context
What is the issue that this ADR addresses? What background do we need?

## Decision
What is the change that we're proposing to do or have done?

## Consequences
What becomes easier or more difficult to do because of this change?
```

## Rules

- Write an ADR when you make a decision that is likely to be relevant to future agents or human contributors.
- An ADR is needed for: technology choices, architectural patterns, API design decisions, data model changes, security decisions.
- An ADR is NOT needed for: routine bug fixes, dependency bumps, configuration tweaks.
- Reference existing ADRs when a decision builds on or conflicts with a prior one (`See also: [NNNN-title](./NNNN-title.md)`).
- Keep ADRs brief. 3-5 sections, ~200-500 words each.

## Existing ADRs

_(none yet — first ADR goes here as `0001-...`)_
