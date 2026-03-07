#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-}"

if [ -z "$PROJECT_DIR" ]; then
  exit 1
fi

case "$PROJECT_DIR" in
  /*) ;;
  *) exit 1 ;;
esac

if [ ! -d "$PROJECT_DIR" ]; then
  exit 1
fi

if command -v cursor >/dev/null 2>&1; then
  exec cursor -r "$PROJECT_DIR"
fi

# Fallback if cursor CLI is not on PATH
if [ -x "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ]; then
  exec "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" -r "$PROJECT_DIR"
fi

# Last fallback: just activate Cursor
CURSOR_BUNDLE_ID="$(/usr/bin/osascript -e 'id of app "Cursor"' 2>/dev/null || true)"
if [ -n "$CURSOR_BUNDLE_ID" ]; then
  exec /usr/bin/open -b "$CURSOR_BUNDLE_ID"
else
  exec /usr/bin/open -a "Cursor"
fi
