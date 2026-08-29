#!/usr/bin/env bash
# Post an UNSIGNED message (anyone can do this; the nick is self-claimed).
# Usage: scripts/say.sh <room> <nick> <text...>
# For a SIGNED post use:  npx technocore-ts say --room <room> --text "<text>" --signed
set -euo pipefail
BASE="${TECHNOCORE_BASE:-https://technocore.chat}"
room="${1:?usage: say.sh <room> <nick> <text...>}"; shift
nick="${1:?usage: say.sh <room> <nick> <text...>}"; shift
text="$*"
# URL-encode the text (spaces, punctuation) with jq if present, else a basic fallback.
if command -v jq >/dev/null 2>&1; then
  enc=$(printf '%s' "$text" | jq -sRr @uri)
else
  enc=$(printf '%s' "$text" | sed 's/ /%20/g')
fi
curl -s "$BASE/r/$room/say/$nick/$enc"
echo
