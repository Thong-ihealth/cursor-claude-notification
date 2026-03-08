#!/usr/bin/env bash
set -euo pipefail

sleep 1.5

CURSOR_FRONTMOST=$(
  /usr/bin/osascript <<'APPLESCRIPT' 2>/dev/null
tell application "System Events"
  if exists application process "Cursor" then
    return frontmost of application process "Cursor"
  else
    return false
  end if
end tell
APPLESCRIPT
)

if [ "$CURSOR_FRONTMOST" = "true" ]; then
  exit 0
fi

INPUT="$(cat || true)"

TITLE="Claude Code"
MESSAGE="Claude needs your attention"
PROJECT_DIR="${PWD:-}"

case "$PROJECT_DIR" in
  /*) ;;
  *) PROJECT_DIR="" ;;
esac

case "$PROJECT_DIR" in
  *".."*|*$'\n'*|*$'\r'*)
    PROJECT_DIR=""
    ;;
esac

if [ -n "$PROJECT_DIR" ] && [ ! -d "$PROJECT_DIR" ]; then
  PROJECT_DIR=""
fi

EVENT_NAME=""
if command -v /opt/homebrew/bin/jq >/dev/null 2>&1; then
  EVENT_NAME="$(printf '%s' "$INPUT" | /opt/homebrew/bin/jq -r '.hook_event_name // empty' 2>/dev/null || true)"
elif command -v /usr/local/bin/jq >/dev/null 2>&1; then
  EVENT_NAME="$(printf '%s' "$INPUT" | /usr/local/bin/jq -r '.hook_event_name // empty' 2>/dev/null || true)"
elif command -v jq >/dev/null 2>&1; then
  EVENT_NAME="$(printf '%s' "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null || true)"
fi

case "$EVENT_NAME" in
  Notification|"")
    MESSAGE="Claude needs your attention"
    ;;
  PermissionRequest)
    MESSAGE="Claude is requesting permission"
    ;;
  Stop)
    MESSAGE="Claude stopped"
    ;;
  TaskCompleted)
    MESSAGE="Claude completed a task"
    ;;
  *)
    MESSAGE="Claude needs your attention"
    ;;
esac

TN=""
for p in /opt/homebrew/bin/terminal-notifier /usr/local/bin/terminal-notifier /usr/bin/terminal-notifier; do
  if [ -x "$p" ]; then
    TN="$p"
    break
  fi
done

if [ -z "$TN" ]; then
  /usr/bin/osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
  exit 0
fi

GROUP_ID="claude.$(/bin/echo -n "$PROJECT_DIR" | /sbin/md5 -q 2>/dev/null || /bin/echo default)"
FOCUS_SCRIPT="$HOME/.claude/hooks/focus-cursor.sh"
CURSOR_BUNDLE_ID="$(/usr/bin/osascript -e 'id of app "Cursor"' 2>/dev/null || true)"

if [ -n "$PROJECT_DIR" ]; then
  "$TN" \
    -group "$GROUP_ID" \
    -title "$TITLE" \
    -message "$MESSAGE" \
    -activate "$CURSOR_BUNDLE_ID" \
    -execute "/bin/bash \"$FOCUS_SCRIPT\" \"$PROJECT_DIR\""
else
  "$TN" \
    -group "$GROUP_ID" \
    -title "$TITLE" \
    -message "$MESSAGE" \
    -activate "$CURSOR_BUNDLE_ID"
fi
