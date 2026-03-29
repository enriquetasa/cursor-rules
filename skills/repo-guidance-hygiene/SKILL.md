# Repo Guidance Hygiene

Use this skill when updating Cursor rule packs to keep guidance clear,
non-duplicated, and easy for contributors to maintain.

## Goals

- Keep `rules/`, `commands/`, `agents/`, and `README.md` aligned.
- Avoid duplicated requirements across multiple files.
- Reduce contradictory or stack-specific assumptions.
- Make onboarding and contribution flow explicit.

## Workflow

1. Inventory
   - List all files in `rules/`, `commands/`, `agents/`, and `skills/`.
   - Confirm README index entries match current filenames.
2. Overlap check
   - Detect duplicated requirements (coverage thresholds, CI expectations,
     logging standards, etc.) across rule files.
   - Keep one canonical source for each concern; cross-reference elsewhere.
3. Consistency check
   - Ensure examples and terminology are consistent across files.
   - Ensure setup/install docs match actual repository structure.
4. Validation
   - Run the local validation script and fix all errors.
   - Re-check that links in README resolve.
5. Final review
   - Keep wording concise, imperative, and implementation-friendly.
   - Prefer concrete instructions over vague guidance.

## Output checklist

- [ ] README index updated for added/removed files
- [ ] No obvious duplicated policy blocks
- [ ] Commands and agents have distinct responsibilities
- [ ] Validation script passes
