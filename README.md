# Claude → Cursor Desktop Notification Setup (Local Only)

This project configures Claude Code hooks to send local macOS desktop notifications when Claude:

- Needs user input
- Requests permission
- Stops or completes a task

Clicking the notification brings the correct Cursor project window to the front.

This setup is:

- Local-only (no webhooks, no external services)
- Uses shell-expanded home paths
- Does not expose prompt content
- Follows shell security best practices
- Works across all projects via `~/.claude/settings.json`

---

# Requirements

- macOS
- Cursor installed
- Claude Code CLI installed
- Homebrew installed
- terminal-notifier
- jq

Install dependencies:

```bash
brew install terminal-notifier jq
```

---

# Installation

## 1. Clone this repo

```bash
git clone <your-repo-url>
cd <your-repo-folder>
```

## 2. Copy scripts into Claude hooks directory

```bash
mkdir -p ~/.claude/hooks
chmod 700 ~/.claude/hooks

cp notify.sh ~/.claude/hooks/
cp focus-cursor.sh ~/.claude/hooks/

chmod 700 ~/.claude/hooks/notify.sh
chmod 700 ~/.claude/hooks/focus-cursor.sh
```

## 3. Install Claude user settings

```bash
cp settings.json ~/.claude/settings.json
chmod 600 ~/.claude/settings.json
```

This repo’s `settings.json` uses `$HOME`, so you do not need to edit your macOS username manually.

If you already have a `~/.claude/settings.json`, merge carefully instead of overwriting.

---

# macOS Notification Permission (Important)

terminal-notifier requires macOS notification permission.

After first run:

1. Open System Settings
2. Go to Notifications
3. Find terminal-notifier
4. Enable:
   - Allow Notifications
   - Banner or Alerts
   - Allow Sound (optional)

If notifications do not appear, check this first.

---

# How It Works

- Claude fires a hook event.
- The hook runs `notify.sh`.
- A macOS desktop notification is shown.
- Clicking the notification runs `focus-cursor.sh`.
- That script activates Cursor and opens the current project directory.

No prompt text or hook payload is displayed.

---

# How to Test

## Test 1 — Script Only

From inside any project folder:

```bash
cd /path/to/project
echo '{"hook_event_name":"Notification"}' | ~/.claude/hooks/notify.sh
```

You should see a desktop notification.

Click it.

Cursor should open or focus that project.

---

## Test 2 — Real Claude Flow

1. Open a project in Cursor.
2. Open Cursor’s integrated terminal.
3. Start Claude:

```bash
claude
```

4. Ask Claude to do something that requires permission or user input.
5. Switch to another app.
6. Wait for the notification.
7. Click the notification.

Cursor should return to the correct project.

---

# Troubleshooting

## No Notification Appears

Check:

```bash
which terminal-notifier
```

If not installed:

```bash
brew install terminal-notifier
```

Test directly:

```bash
terminal-notifier -title "Test" -message "Hello"
```

Also verify macOS notification permissions.

---

## Click Does Nothing

Ensure `focus-cursor.sh` is executable:

```bash
chmod 700 ~/.claude/hooks/focus-cursor.sh
```

Confirm Cursor bundle ID works:

```bash
osascript -e 'id of app "Cursor"'
```

Test focus script manually:

```bash
~/.claude/hooks/focus-cursor.sh "$(pwd)"
```

---

## Claude Hook Not Firing

Restart Claude after updating settings.

Validate JSON:

```bash
cat ~/.claude/settings.json | jq .
```

Check that the hook command still points to:

```bash
/bin/bash "$HOME/.claude/hooks/notify.sh"
```

---

# Security Notes

- All scripts run locally.
- No network calls are made.
- No Claude prompt data is shown or transmitted.
- Paths are validated before being used.
- Files use restrictive permissions.
- No dynamic shell construction from hook payloads.

This setup minimizes attack surface while providing reliable local workflow notifications.
