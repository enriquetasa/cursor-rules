#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="${1:-}"

if [[ -z "${PROJECT_ROOT}" || ! -d "${PROJECT_ROOT}" ]]; then
  echo "quality-gates error: provide a valid project root path." >&2
  exit 1
fi

QUALITY_SCRIPT="${PROJECT_ROOT}/scripts/quality-gates.sh"

if [[ -f "${QUALITY_SCRIPT}" ]]; then
  bash "${QUALITY_SCRIPT}"
  exit 0
fi

echo "quality-gates error: no project quality gate script found." >&2
echo "Expected: ${QUALITY_SCRIPT}" >&2
echo "Add a project script that runs lint/type/test/build/security checks." >&2
exit 1
