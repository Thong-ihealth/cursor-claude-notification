#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-}"

# Must be non-empty
if [ -z "$PROJECT_DIR" ]; then
  exit 1
fi

# Must be absolute
case "$PROJECT_DIR" in
  /*) ;;
  *) exit 1 ;;
esac

# Reject newline / carriage return
case "$PROJECT_DIR" in
  *$'\n'*|*$'\r'*)
    exit 1
    ;;
esac

# Must exist and be a directory
if [ ! -d "$PROJECT_DIR" ]; then
  exit 1
fi

# Resolve to canonical path
if [ -x /usr/bin/realpath ]; then
  PROJECT_DIR="$(/usr/bin/realpath "$PROJECT_DIR")"
fi

# Re-check resolved path
case "$PROJECT_DIR" in
  /*) ;;
  *) exit 1 ;;
esac

case "$PROJECT_DIR" in
  *$'\n'*|*$'\r'*)
    exit 1
    ;;
esac

if [ ! -d "$PROJECT_DIR" ]; then
  exit 1
fi

CURSOR_BUNDLE_ID="$(/usr/bin/osascript -e 'id of app "Cursor"' 2>/dev/null || true)"

if [ -n "$CURSOR_BUNDLE_ID" ]; then
  /usr/bin/open -b "$CURSOR_BUNDLE_ID" "$PROJECT_DIR"
else
  /usr/bin/open -a "Cursor" "$PROJECT_DIR"
fi
