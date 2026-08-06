#!/bin/bash
# Statusline for Claude Code. Mirrors the ~/.bashrc PS1 aesthetic
# (user@host:cwd) and adds git branch/dirty state + current model.
# Colorblind-safe palette (green/blue/cyan/yellow) to suit daltonized themes.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
model_id=$(echo "$input" | jq -r '.model.id // empty')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')

# Shorten $HOME to ~ (assign literal tilde via a var so no backslash leaks in)
tilde="~"
cwd_display="${cwd/#$HOME/$tilde}"

user="$(whoami)"
host="$(hostname -s)"

# Git branch + dirty marker (yellow *), only inside a work tree.
branch_seg=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  b=$(git -C "$cwd" branch --show-current 2>/dev/null)
  [ -z "$b" ] && b=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  dirty=""
  [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ] && dirty="\033[01;33m*\033[00m"
  branch_seg=" \033[00;36m ${b}\033[00m${dirty}"
fi

# Model, dimmed.
model_seg=""
[ -n "$model" ] && model_seg=" \033[02m${model}\033[00m"

# Context window usage. Prefer the context_window object Claude Code now
# includes in the statusline payload (has the real window size, so [1m]
# models show /1M); fall back to transcript parsing on older versions.
ctx_seg=""
used=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
limit=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

if ! [ "$used" -gt 0 ] 2>/dev/null && [ -n "$transcript" ] && [ -f "$transcript" ]; then
  # Reverse the file (tail -r on macOS/BSD, tac on GNU) so the newest
  # matching usage line comes first.
  if command -v tac >/dev/null 2>&1; then reverse="tac"; else reverse="tail -r"; fi
  used=$($reverse "$transcript" 2>/dev/null | jq -rc \
    'select(.type=="assistant" and (.isSidechain|not) and .message.usage)
     | .message.usage
     | (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)' \
    2>/dev/null | head -1)
fi

if [ -n "$used" ] && [ "$used" -gt 0 ] 2>/dev/null; then
  if ! [ "$limit" -gt 0 ] 2>/dev/null; then
    # Old payload without context_window: guess 1M for [1m] models.
    case "${model_id}${model}" in
      *1m*|*1M*) limit=1000000 ;;
      *)         limit=200000 ;;
    esac
  fi
  if [ "$limit" -ge 1000000 ]; then limit_lbl="$(( limit / 1000000 ))M"
  else                              limit_lbl="$(( limit / 1000 ))k"
  fi

  pct=$(( used * 100 / limit ))

  # k-formatted used tokens (one decimal below 10k).
  if [ "$used" -ge 10000 ]; then
    used_lbl="$(( (used + 500) / 1000 ))k"
  else
    used_lbl="$(awk "BEGIN{printf \"%.1fk\", $used/1000}")"
  fi

  # green <50%, yellow <80%, red otherwise.
  if   [ "$pct" -lt 50 ]; then ctx_color="00;32"
  elif [ "$pct" -lt 80 ]; then ctx_color="00;33"
  else                         ctx_color="01;31"
  fi
  ctx_seg=" \033[${ctx_color}m ${used_lbl}/${limit_lbl} ${pct}%\033[00m"
fi

printf "\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m%b%b%b" \
  "$user" "$host" "$cwd_display" "$branch_seg" "$model_seg" "$ctx_seg"
