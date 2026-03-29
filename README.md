# Cursor Rules

Opinionated global Cursor guidance for engineering quality, delivery
consistency, and repository audits.

## What this repository is

This repository is a source-of-truth for global Cursor assets:

- `rules/` for `.mdc` rule files
- `commands/` for command prompts
- `agents/` for reusable role definitions
- `skills/` for reusable skill workflows

`setup.sh` symlinks these assets into `~/.cursor/` so updates in this repo are
immediately reflected in Cursor.

## Installation

### 1) Clone this repository

```bash
git clone git@github.com:enrique-tasa/cursor-rules.git "$HOME/Code/cursor-rules"
```

### 2) Run setup

```bash
cd "$HOME/Code/cursor-rules"
./setup.sh
```

This script creates and updates symlinks under:

- `~/.cursor/rules`
- `~/.cursor/commands`
- `~/.cursor/agents`
- `~/.cursor/skills`

### 3) Restart Cursor

Restart Cursor so it re-indexes newly linked assets.

### 4) Install Git hooks

Install repository-managed hooks that enforce rule quality and commit standards:

```bash
bash scripts/install-git-hooks.sh
```

Installed hooks:

- `pre-commit`: runs `bash scripts/validate-rules.sh`
- `commit-msg`: enforces commit subject/body conventions
- `pre-push`: reruns validation and checks pushed commit messages

## Use Hooks In Any Project

To install these standards hooks into another git repository:

```bash
cd "$HOME/Code/cursor-rules"
bash scripts/install-project-hooks.sh "/absolute/path/to/your-project"
```

This installs `pre-commit`, `commit-msg`, and `pre-push` into the target
project's `.git/hooks` directory.

Requirement in each target project:

- `scripts/quality-gates.sh` must exist and run project-specific quality checks
  (lint/type/test/build/security as applicable).

## How this interacts with project-local rules

- These rules are global defaults.
- Project-local `.cursor/rules` can be used for repository-specific guidance.
- When multiple rules apply, prefer:
  1. safety/stability requirements,
  2. explicit user instructions,
  3. project-local constraints over broad global defaults.

## Rule precedence and conflict handling

Some rules intentionally pull in different directions (for example cost vs
performance). Apply this order:

1. Correctness and safety first.
2. Simplicity that meets current requirements second.
3. Performance and scaling improvements when they are justified by usage.

Avoid premature complexity. Fix clear inefficiencies (N+1, unnecessary repeated
work, missing caching opportunities) without over-architecting.

### Conflict matrix

| Conflict | Default decision |
| --- | --- |
| Safety vs speed | choose safety |
| Correctness vs convenience | choose correctness |
| Simplicity vs pre-scaling | choose simplicity unless metrics justify scaling |
| Performance vs cost | remove obvious waste first, then optimize bottlenecks |
| Strict process vs incident response | stabilize incident first, then restore standards |

## Repository index

### Rules (`rules/`)

- `api-design-standards.mdc`: API contract, auth, and response conventions.
- `backend-standards.mdc`: backend architecture and service organization.
- `code-quality-standards.mdc`: lint/format/type/security expectations.
- `cost-efficiency.mdc`: cost-aware engineering and infrastructure choices.
- `deployment-standards.mdc`: containerization, CI/CD, and release norms.
- `frontend-standards.mdc`: frontend architecture and quality conventions.
- `git-commit-standards.mdc`: commit structure and message quality.
- `mobile-standards.mdc`: mobile client architecture and delivery practices.
- `observability-logging.mdc`: structured logging and error handling guidance.
- `performance-scalability.mdc`: performance and scalability requirements.
- `quality-gates.mdc`: canonical merge-blocking lint/type/test/coverage checks.
- `real-time-updates.mdc`: websocket and real-time data synchronization.
- `separation-of-concerns.mdc`: backend vs frontend responsibility boundaries.
- `test-driven-development.mdc`: TDD workflow expectations.
- `testing-requirements.mdc`: coverage, test layering, and CI checks.

### Commands (`commands/`)

- `audit.mdc`: fast, command-driven audit for docs/config/wiring mismatches.
- `implement.mdc`: end-to-end implementation protocol with validation output.

### Agents (`agents/`)

- `staff-software-engineer-auditor.md`: deep technical coherence audits.
- `devops-deployment-engineer.md`: CI/CD and deployment automation specialist.
- `technical-product-manager.md`: plan quality and journey completeness reviews.

### Skills (`skills/`)

- `skills/repo-guidance-hygiene/SKILL.md`: keeps rules/agents/commands aligned
  and maintainable.

### Docs (`docs/`)

- `docs/rule-template.md`: standard template for authoring rule files.

## When to use rules vs commands vs agents

- Use **rules** for always-on guardrails and coding standards.
- Use **commands** for repeatable one-shot workflows.
- Use **agents** for deeper specialized execution with explicit role context.

Audit guidance:

- Use `commands/audit.mdc` for quick audits and lightweight fixes.
- Use `agents/staff-software-engineer-auditor.md` for broader, staff-level
  investigations with deeper remediation strategy.

## Troubleshooting

### Rule does not seem to apply

- Confirm symlink exists in `~/.cursor/...` and points into this repository.
- Ensure glob patterns match your project paths.
- Restart Cursor to refresh indexing.

### Setup script ran but nothing linked

- Verify repository exists at `$HOME/Code/cursor-rules`.
- Check that expected folders (`rules`, `commands`, `agents`, `skills`) exist.
- Re-run `./setup.sh`.

### Updated a file but Cursor still uses old behavior

- Restart Cursor.
- Re-run setup to refresh any broken symlinks.

## Contributing

When changing guidance:

- keep language explicit and non-contradictory,
- avoid duplicated requirements across files,
- keep examples practical and aligned with the rest of the stack,
- update this README index if files are added/removed/renamed.

Authoring expectations:

- Rules should follow the template in `docs/rule-template.md`.
- Use this section structure in rule content:
  - `Hard Requirements`
  - `Opinionated Defaults`
  - `Exceptions`
  - `Acceptance Checks`
- Keep mandatory checks centralized in `rules/quality-gates.mdc`.
- Use concise `Do / Do not / Why` phrasing in rule requirements.

Run local validation before opening a PR:

```bash
bash scripts/validate-rules.sh
```

Install or refresh hooks after pulling hook updates:

```bash
bash scripts/install-git-hooks.sh
```

Install cross-project hooks:

```bash
bash scripts/install-project-hooks.sh "/absolute/path/to/your-project"
```

## Glossary

- `hard requirement`: merge-impacting mandatory behavior.
- `opinionated default`: preferred implementation approach that can vary by repo.
- `exception`: explicitly allowed deviation with constraints and follow-up.
- `acceptance check`: concrete signal that rule intent was satisfied.
- `quality gate`: required automated check before merge/deploy.

## Changelog

### 2026-03-28

- Added canonical `quality-gates.mdc`.
- Migrated all rules to shared structure and explicit exception handling.
- Added strict output/input contracts to all agents.
- Added rule authoring template and validation checks for required sections.
