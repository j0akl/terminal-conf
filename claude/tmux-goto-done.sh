#!/usr/bin/env bash
# Jump to a Claude pane that finished while you were looking elsewhere.
#
# With a pane id, go to that pane — notifications pass their own id, so clicking
# an older notification still lands on the pane that produced it rather than the
# most recent finish. With no id, go to the most recent, which is what the tmux
# key binding does.
#
#   tmux-goto-done.sh                       # most recent
#   tmux-goto-done.sh %8                    # that pane
#   tmux-goto-done.sh --focus-terminal %8   # and bring kitty forward
set -uo pipefail

focus_terminal=0
if [ "${1:-}" = "--focus-terminal" ]; then
  focus_terminal=1
  shift
fi

pane=${1:-}
[ -n "$pane" ] || pane=$(tmux show -gv @claude_last_done 2>/dev/null)

if [ -z "$pane" ]; then
  tmux display-message "no finished Claude pane recorded" 2>/dev/null
  exit 0
fi

# The pane may have been closed between the notification and the click. Test
# membership rather than the exit code: `display -p -t <unknown>` exits 0 and
# expands the format to empty fields instead of failing.
if ! tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qx -- "$pane"; then
  tmux display-message "Claude pane $pane is gone" 2>/dev/null
  exit 0
fi
target=$(tmux display -p -t "$pane" '#{session_name}:#{window_index}' 2>/dev/null)

# switch-client handles the pane living in another session, but needs a client
# named explicitly: when this runs from a notification click there is no
# surrounding tmux to infer one from.
client=$(tmux list-clients -F '#{client_name}' 2>/dev/null | head -1)
if [ -n "$client" ]; then
  tmux switch-client -c "$client" -t "$target" 2>/dev/null
else
  tmux select-window -t "$target" 2>/dev/null
fi
tmux select-pane -t "$pane" 2>/dev/null

# after-select-pane clears @claude_done, so arriving removes the marker.

[ "$focus_terminal" = 1 ] && open -a kitty 2>/dev/null
exit 0
