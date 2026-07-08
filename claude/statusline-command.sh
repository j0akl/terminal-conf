#!/bin/bash
# Statusline for Claude Code. Mirrors the ~/.bashrc PS1 aesthetic
# (user@host:cwd) and adds git branch/dirty state + current model.
# Colorblind-safe palette (green/blue/cyan/yellow) to suit daltonized themes.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Shorten $HOME to ~
cwd_display="${cwd/#$HOME/\~}"

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

printf "\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m%b%b" \
  "$user" "$host" "$cwd_display" "$branch_seg" "$model_seg"
