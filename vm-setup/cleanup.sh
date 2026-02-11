#!/usr/bin/env bash
set -euo pipefail

# Deletes old recordings to free disk space.
# Usage: cleanup.sh [days]   (default: 7)

RECORDINGS_DIR="$HOME/give-claude-a-computer/recordings"
DAYS="${1:-7}"

if [[ ! -d "$RECORDINGS_DIR" ]]; then
  echo "Recordings directory not found: $RECORDINGS_DIR"
  exit 0
fi

echo "==> Disk usage before cleanup"
du -sh "$RECORDINGS_DIR"

# Find and delete old recordings
OLD_FILES=$(find "$RECORDINGS_DIR" -name '*.mp4' -mtime +"$DAYS" -type f)

if [[ -z "$OLD_FILES" ]]; then
  echo "No recordings older than $DAYS days"
else
  echo ""
  echo "Deleting recordings older than $DAYS days:"
  echo "$OLD_FILES" | while read -r f; do
    echo "  $(basename "$f") ($(du -h "$f" | cut -f1))"
    rm "$f"
  done
fi

echo ""
echo "==> Disk usage after cleanup"
du -sh "$RECORDINGS_DIR"
echo ""
echo "Total recordings: $(find "$RECORDINGS_DIR" -name '*.mp4' -type f | wc -l)"
df -h / | tail -1 | awk '{print "Disk free: " $4 " (" $5 " used)"}'
