#!/usr/bin/env bash
# Claude Code Stop hook — macOS notification when a turn finishes, skipped for
# the pane you are actively watching.
#
# osascript is the only channel that survives this setup: kitty's OSC 99 never
# arrives through tmux (verified both raw and tmux-wrapped), and kitty.conf sets
# enable_audio_bell no + visual_bell_duration 0.0, so escape-code channels are
# silent. osascript talks to Notification Center directly and ignores the tty.
#
# CLAUDE_NOTIFY_DRY_RUN=1 prints the gate decision instead of notifying.
set -uo pipefail

TERMINAL_APP=${CLAUDE_NOTIFY_TERMINAL_APP:-kitty}

payload=$(cat)

# You are watching this pane only if all four hold: it is the focused pane, in
# the current window, of an attached session, with the terminal frontmost.
# Any check that cannot be answered falls through to notifying — missing a
# finished turn is worse than one redundant notification.
watching_this_pane() {
  local state pane_active window_active session_attached front
  state=$(tmux display -p -t "${TMUX_PANE:-}" \
    '#{pane_active}:#{window_active}:#{session_attached}' 2>/dev/null) || return 1
  IFS=: read -r pane_active window_active session_attached <<<"$state"
  [ "$pane_active" = 1 ] || return 1
  [ "$window_active" = 1 ] || return 1
  [ "${session_attached:-0}" -ge 1 ] 2>/dev/null || return 1

  # lsappinfo reads the frontmost app without needing Accessibility permission,
  # unlike the System Events route. Output looks like: "LSDisplayName"="kitty"
  front=$(lsappinfo info -only name "$(lsappinfo front 2>/dev/null)" 2>/dev/null) || return 1
  case "$front" in
    *"\"$TERMINAL_APP\""*) return 0 ;;
    *) return 1 ;;
  esac
}

if watching_this_pane; then
  [ -n "${CLAUDE_NOTIFY_DRY_RUN:-}" ] && echo "suppress: you are watching this pane"
  exit 0
fi
[ -n "${CLAUDE_NOTIFY_DRY_RUN:-}" ] && echo "notify: this pane is not in front of you"

dir=$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$dir" ] || dir=$PWD

# Include the pane index, not just session:window — several Claude sessions are
# often split across panes of one window, so the window alone does not say which
# one finished.
# window_name is omitted deliberately: tmux automatic-rename sets it to the
# running command, which for a Claude pane is just the version string.
where=$(tmux display -p -t "${TMUX_PANE:-}" \
  '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)
[ -n "$where" ] || where="turn complete"

[ -n "${CLAUDE_NOTIFY_DRY_RUN:-}" ] && exit 0

# argv form keeps the directory and window names out of the AppleScript source,
# so a quote in either cannot break or inject into the script.
osascript \
  -e 'on run argv' \
  -e 'display notification (item 2 of argv) with title (item 1 of argv) sound name "Ping"' \
  -e 'end run' \
  "Claude Code — $(basename "$dir")" "$where" >/dev/null 2>&1 || true
