#!/usr/bin/env bash
# Usage: ./new-room.sh <room-name>
# Creates a room under rooms/ that inherits the shared .claude/ config,
# scaffolds scans/ and a fresh notes.md, then tells you how to start.
#
# Rooms live in rooms/ which is git-ignored — your scans, notes, creds,
# and flags never get committed. The shared .claude/ config at the repo
# root IS tracked, and rooms inherit it because rooms/ sits underneath it.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <room-name>"
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOM="$ROOT/rooms/$1"

mkdir -p "$ROOM/scans"

if [ ! -f "$ROOM/notes.md" ]; then
  cat > "$ROOM/notes.md" <<EOF
# $1 — Notes

## Target
- IP:
- Hostname:
- OS guess:

## Open Ports & Services
| Port | Service | Version | Notes |
|------|---------|---------|-------|

## Credentials

## Foothold / Access

## Flags
- User:
- Root:

## Open leads / To try
EOF
fi

echo "Room ready: $ROOM"
echo "Start with:  cd rooms/$1 && claude"
echo "The shared .claude/ config is inherited from $ROOT."
