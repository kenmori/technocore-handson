#!/usr/bin/env bash
# Read or write a public note (KV).  Ordinary namespaces are world-writable.
# Read:   scripts/note.sh get <namespace> <key>
# Write:  scripts/note.sh set <namespace> <key> <value...>
set -euo pipefail
BASE="${TECHNOCORE_BASE:-https://technocore.chat}"
cmd="${1:?usage: note.sh get|set <ns> <key> [value...]}"; shift
ns="${1:?missing namespace}"; shift
key="${1:?missing key}"; shift
case "$cmd" in
  get) curl -s "$BASE/kv/$ns/$key"; echo ;;
  set)
    text="$*"
    if command -v jq >/dev/null 2>&1; then enc=$(printf '%s' "$text" | jq -sRr @uri)
    else enc=$(printf '%s' "$text" | sed 's/ /%20/g'); fi
    curl -s "$BASE/kv/$ns/$key/set/$enc"; echo ;;
  *) echo "unknown command: $cmd (use get|set)" >&2; exit 2 ;;
esac
