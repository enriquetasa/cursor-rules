# Rule Authoring Template

Use this template for every `rules/*.mdc` file.

```md
---
description: <short purpose>
globs: <optional glob or list of globs>
alwaysApply: <true|false>
---

# <Rule Name>

<one-line intent>

## Hard Requirements

- Do: <mandatory behavior>
- Do: <mandatory behavior>
- Do not: <explicit anti-pattern>
- Why: <why this is mandatory>

## Opinionated Defaults

- <preferred default>
- <preferred default>

## Exceptions

- <when exceptions are allowed>
- <constraints/required follow-up for exceptions>

## Acceptance Checks

- <how to verify this rule was applied>
- <how to verify this rule was applied>
```

## Guidance

- Keep bullets action-oriented and concise.
- Keep one canonical rule per concern to avoid duplication.
- Prefer references to canonical rules (`quality-gates.mdc`) over repeated text.
- Update `README.md` index when adding/removing/renaming rules.
