#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$REPO_ROOT" <<'PY'
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1])
errors: list[str] = []


def parse_frontmatter(path: pathlib.Path) -> dict[str, str] | None:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    end_idx = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end_idx = i
            break
    if end_idx is None:
        return None
    data: dict[str, str] = {}
    for line in lines[1:end_idx]:
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip()
    return data


def require_frontmatter(path: pathlib.Path, keys: list[str]) -> None:
    parsed = parse_frontmatter(path)
    if parsed is None:
        errors.append(f"{path}: missing or invalid frontmatter block")
        return
    for key in keys:
        if key not in parsed:
            errors.append(f"{path}: missing frontmatter key '{key}'")


def require_headings(path: pathlib.Path, headings: list[str]) -> None:
    text = path.read_text(encoding="utf-8")
    for heading in headings:
        if f"## {heading}" not in text:
            errors.append(f"{path}: missing heading '## {heading}'")


def get_section_text(text: str, heading: str) -> str:
    pattern = re.compile(
        rf"^## {re.escape(heading)}\s*$([\s\S]*?)(?=^## |\Z)",
        re.MULTILINE,
    )
    match = pattern.search(text)
    return match.group(1) if match else ""


def require_quality_markers(path: pathlib.Path) -> None:
    text = path.read_text(encoding="utf-8")
    hard_requirements = get_section_text(text, "Hard Requirements")
    required_markers = ["Do:", "Do not:", "Why:"]
    for marker in required_markers:
        if marker not in hard_requirements:
            errors.append(
                f"{path}: 'Hard Requirements' section missing marker '{marker}'"
            )


# 1) Frontmatter checks
for path in sorted((repo / "rules").glob("*.mdc")):
    require_frontmatter(path, ["description", "alwaysApply"])
    require_headings(
        path,
        [
            "Hard Requirements",
            "Opinionated Defaults",
            "Exceptions",
            "Acceptance Checks",
        ],
    )
    require_quality_markers(path)

for path in sorted((repo / "commands").glob("*.mdc")):
    require_frontmatter(path, ["description", "alwaysApply"])

for path in sorted((repo / "agents").glob("*.md")):
    require_frontmatter(path, ["name", "description"])
    require_headings(
        path,
        [
            "Input Contract",
            "Output Schema",
            "Escalation Boundaries",
            "Effort Budget",
            "Definition of Done",
        ],
    )


# 2) README link existence checks
readme = repo / "README.md"
readme_text = readme.read_text(encoding="utf-8")
link_pattern = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
for target in link_pattern.findall(readme_text):
    if target.startswith(("http://", "https://", "mailto:", "#")):
        continue
    if target.startswith("/"):
        # Treat leading "/" links as repository-root-relative markdown paths.
        candidate = (repo / target.lstrip("/")).resolve()
    else:
        candidate = (repo / target).resolve()
    if not candidate.exists():
        errors.append(f"README.md: broken link target '{target}'")


# 3) Inventory consistency (README should mention each guidance file)
readme_targets = [
    sorted((repo / "rules").glob("*.mdc")),
    sorted((repo / "commands").glob("*.mdc")),
    sorted((repo / "agents").glob("*.md")),
]
for group in readme_targets:
    for path in group:
        if path.name not in readme_text:
            errors.append(
                f"README.md: expected inventory reference for '{path.name}'"
            )

skills_dir = repo / "skills"
if skills_dir.exists():
    for skill_path in sorted(skills_dir.glob("*/SKILL.md")):
        rel = skill_path.relative_to(repo).as_posix()
        if rel not in readme_text and skill_path.parent.name not in readme_text:
            errors.append(
                f"README.md: expected inventory reference for '{rel}'"
            )

if errors:
    print("Validation failed:")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("Validation passed.")
print(
    "Checked frontmatter, required headings, quality markers, README links, and inventory consistency."
)
PY
