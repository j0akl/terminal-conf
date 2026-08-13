#!/usr/bin/env bash
set -uo pipefail

TERMINAL_APP=${CODEX_NOTIFY_TERMINAL_APP:-kitty}
payload=$(cat)
event=$(printf '%s' "$payload" | jq -r '.hook_event_name // empty' 2>/dev/null)

finish() {
  printf '{}\n'
}

auto_review_enabled() {
  grep -Eq \
    '^[[:space:]]*approvals_reviewer[[:space:]]*=[[:space:]]*"auto_review"[[:space:]]*(#.*)?$' \
    "${CODEX_HOME:-$HOME/.codex}/config.toml" 2>/dev/null
}

case "$event" in
  Stop) status="turn complete" ;;
  PermissionRequest)
    if auto_review_enabled; then
      finish
      exit 0
    fi
    status="approval needed"
    ;;
  *) finish; exit 0 ;;
esac

watching_this_pane() {
  local state pane_active window_active session_attached front
  state=$(tmux display -p -t "${TMUX_PANE:-}" \
    '#{pane_active}:#{window_active}:#{session_attached}' 2>/dev/null) || return 1
  IFS=: read -r pane_active window_active session_attached <<<"$state"
  [ "$pane_active" = 1 ] || return 1
  [ "$window_active" = 1 ] || return 1
  [ "${session_attached:-0}" -ge 1 ] 2>/dev/null || return 1

  front=$(lsappinfo info -only name "$(lsappinfo front 2>/dev/null)" 2>/dev/null) || return 1
  case "$front" in
    *"\"$TERMINAL_APP\""*) return 0 ;;
    *) return 1 ;;
  esac
}

if watching_this_pane; then
  [ -n "${CODEX_NOTIFY_DRY_RUN:-}" ] && echo "suppress: you are watching this pane" >&2
  finish
  exit 0
fi
[ -n "${CODEX_NOTIFY_DRY_RUN:-}" ] && echo "notify: this pane is not in front of you" >&2

dir=$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$dir" ] || dir=$PWD

pane=${TMUX_PANE:-}
if [ -n "$pane" ] && tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qx -- "$pane"; then
  where=$(tmux display -p -t "$pane" \
    '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)
else
  pane=""
fi
[ -n "${where:-}" ] || where="$status"

if [ -n "${CODEX_NOTIFY_DRY_RUN:-}" ]; then
  finish
  exit 0
fi

title="Codex — $(basename "$dir")"

if [ -n "$pane" ]; then
  tmux set -p -t "$pane" @claude_done 1 2>/dev/null
  tmux set -g @claude_last_done "$pane" 2>/dev/null
fi

if [ -n "$pane" ] && command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier \
    -title "$title" \
    -message "$where — $status — click to jump" \
    -sound Ping \
    -group "codex-$pane" \
    -execute "$HOME/.claude/tmux-goto-done.sh --focus-terminal $pane" \
    >/dev/null 2>&1 && finish && exit 0
fi

osascript \
  -e 'on run argv' \
  -e 'display notification (item 2 of argv) with title (item 1 of argv) sound name "Ping"' \
  -e 'end run' \
  "$title" "$where — $status — C-a g to jump" >/dev/null 2>&1 || true

finish
