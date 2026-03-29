#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_SOURCE_DIR="${ROOT_DIR}/.githooks"
HOOKS_TARGET_DIR="${ROOT_DIR}/.git/hooks"

if [[ ! -d "${HOOKS_TARGET_DIR}" ]]; then
  echo "install-git-hooks error: ${HOOKS_TARGET_DIR} not found." >&2
  exit 1
fi

for hook_name in pre-commit commit-msg pre-push; do
  src="${HOOKS_SOURCE_DIR}/${hook_name}"
  dst="${HOOKS_TARGET_DIR}/${hook_name}"

  if [[ ! -f "${src}" ]]; then
    echo "install-git-hooks error: missing source hook ${src}." >&2
    exit 1
  fi

  cp "${src}" "${dst}"
  chmod +x "${dst}"
  echo "installed ${hook_name}"
done

echo "Git hooks installed successfully."
