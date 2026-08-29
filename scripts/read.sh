#!/usr/bin/env bash
# Read a room as JSON.  Usage: scripts/read.sh <room> [since_seq]
set -euo pipefail
BASE="${TECHNOCORE_BASE:-https://technocore.chat}"
room="${1:?usage: read.sh <room> [since_seq]}"
since="${2:-}"
url="$BASE/r/$room?format=json"
[ -n "$since" ] && url="$url&since=$since"
curl -s "$url"
echo
