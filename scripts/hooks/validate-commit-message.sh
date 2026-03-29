#!/usr/bin/env bash

set -euo pipefail

MESSAGE_FILE="${1:-}"

if [[ -z "${MESSAGE_FILE}" || ! -f "${MESSAGE_FILE}" ]]; then
  echo "commit-msg validation error: provide a valid message file path." >&2
  exit 1
fi

mapfile -t RAW_LINES < "${MESSAGE_FILE}"

strip_cr() {
  local value="$1"
  printf "%s" "${value%$'\r'}"
}

is_comment_or_empty() {
  local line="$1"
  [[ -z "${line}" || "${line}" =~ ^[[:space:]]*# ]]
}

SUBJECT_INDEX=-1
SUBJECT=""

for i in "${!RAW_LINES[@]}"; do
  line="$(strip_cr "${RAW_LINES[$i]}")"
  if is_comment_or_empty "${line}"; then
    continue
  fi
  SUBJECT_INDEX="$i"
  SUBJECT="${line}"
  break
done

if [[ "${SUBJECT_INDEX}" -lt 0 ]]; then
  echo "commit-msg validation error: subject line is required." >&2
  exit 1
fi

if [[ ${#SUBJECT} -gt 50 ]]; then
  echo "commit-msg validation error: subject must be <= 50 chars." >&2
  exit 1
fi

if [[ "${SUBJECT}" =~ \.$ ]]; then
  echo "commit-msg validation error: subject must not end with a period." >&2
  exit 1
fi

if [[ ! "${SUBJECT}" =~ ^[A-Z] ]]; then
  echo "commit-msg validation error: subject must start with a capital letter." >&2
  exit 1
fi

FIRST_WORD="${SUBJECT%% *}"
if [[ "${FIRST_WORD}" =~ ^(Added|Fixed|Updated|Refactored|Implemented|Created|Removed)$ ]]; then
  echo "commit-msg validation error: use imperative mood in subject." >&2
  exit 1
fi

HAS_BODY=false
for (( i=SUBJECT_INDEX+1; i<${#RAW_LINES[@]}; i++ )); do
  line="$(strip_cr "${RAW_LINES[$i]}")"
  if is_comment_or_empty "${line}"; then
    continue
  fi
  HAS_BODY=true
  break
done

if [[ "${HAS_BODY}" == true ]]; then
  NEXT_LINE="$(strip_cr "${RAW_LINES[$((SUBJECT_INDEX+1))]:-}")"
  if [[ -n "${NEXT_LINE}" ]]; then
    echo "commit-msg validation error: keep a blank line between subject and body." >&2
    exit 1
  fi
fi

for (( i=SUBJECT_INDEX+2; i<${#RAW_LINES[@]}; i++ )); do
  line="$(strip_cr "${RAW_LINES[$i]}")"
  if is_comment_or_empty "${line}"; then
    continue
  fi
  if [[ ${#line} -gt 72 ]]; then
    echo "commit-msg validation error: body lines must be <= 72 chars." >&2
    echo "offending line ${i}: ${line}" >&2
    exit 1
  fi
done
