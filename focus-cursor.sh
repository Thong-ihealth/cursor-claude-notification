#!/usr/bin/env bash
set -euo pipefail

CURSOR_BUNDLE_ID="$(/usr/bin/osascript -e 'id of app "Cursor"' 2>/dev/null || true)"

if [ -n "$CURSOR_BUNDLE_ID" ]; then
  /usr/bin/open -b "$CURSOR_BUNDLE_ID"
else
  /usr/bin/open -a "Cursor"
fi
