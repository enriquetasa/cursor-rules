#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: bash scripts/install-project-hooks.sh /path/to/project" >&2
  exit 1
fi

CURSOR_RULES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_PROJECT="$(cd "$1" && pwd)"

if [[ ! -d "${TARGET_PROJECT}/.git" ]]; then
  echo "install-project-hooks error: ${TARGET_PROJECT} is not a git repository." >&2
  exit 1
fi

TARGET_HOOKS_DIR="${TARGET_PROJECT}/.git/hooks"
mkdir -p "${TARGET_HOOKS_DIR}"

cat > "${TARGET_HOOKS_DIR}/pre-commit" <<EOF
#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="\$(git rev-parse --show-toplevel)"
bash "${CURSOR_RULES_ROOT}/scripts/hooks/run-project-quality-gates.sh" "\${PROJECT_ROOT}"
EOF

cat > "${TARGET_HOOKS_DIR}/commit-msg" <<EOF
#!/usr/bin/env bash

set -euo pipefail

bash "${CURSOR_RULES_ROOT}/scripts/hooks/validate-commit-message.sh" "\${1}"
EOF

cat > "${TARGET_HOOKS_DIR}/pre-push" <<EOF
#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="\$(git rev-parse --show-toplevel)"
COMMIT_VALIDATOR="${CURSOR_RULES_ROOT}/scripts/hooks/validate-commit-message.sh"
QUALITY_GATES_RUNNER="${CURSOR_RULES_ROOT}/scripts/hooks/run-project-quality-gates.sh"

bash "\${QUALITY_GATES_RUNNER}" "\${PROJECT_ROOT}"

validate_commit_range() {
  local commit
  local tmp_file

  while IFS= read -r commit; do
    [[ -z "\${commit}" ]] && continue
    tmp_file="\$(mktemp)"
    git show -s --format=%B "\${commit}" > "\${tmp_file}"
    if ! bash "\${COMMIT_VALIDATOR}" "\${tmp_file}"; then
      rm -f "\${tmp_file}"
      echo "pre-push validation error: commit \${commit} failed message checks." >&2
      exit 1
    fi
    rm -f "\${tmp_file}"
  done < <(git rev-list "\$@")
}

while read -r local_ref local_sha remote_ref remote_sha; do
  [[ "\${local_sha}" == "0000000000000000000000000000000000000000" ]] && continue

  if [[ "\${remote_sha}" == "0000000000000000000000000000000000000000" ]]; then
    validate_commit_range "\${local_sha}" --not --remotes
  else
    validate_commit_range "\${remote_sha}..\${local_sha}"
  fi
done
EOF

chmod +x \
  "${TARGET_HOOKS_DIR}/pre-commit" \
  "${TARGET_HOOKS_DIR}/commit-msg" \
  "${TARGET_HOOKS_DIR}/pre-push"

echo "Installed project hooks into: ${TARGET_PROJECT}"
echo "Required in target project: scripts/quality-gates.sh"
