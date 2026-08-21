#!/usr/bin/env bash
# Install Jake's terminal config (tmux + neovim + Codex + Claude) on a fresh machine.
# Installs the required tools, then symlinks the configs into place.
# Safe to re-run: existing non-symlink files are backed up to *.bak.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf "\033[01;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[01;33m!!\033[0m %s\n" "$1"; }

# JetBrainsMono Nerd Font — the terminal font this setup expects.
FONT_ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

font_present() {
  if command -v fc-list >/dev/null 2>&1; then
    fc-list | grep -qi "JetBrainsMono Nerd Font"
  else # macOS has no fontconfig; check the user font dir directly
    ls "$HOME/Library/Fonts"/*JetBrainsMono* >/dev/null 2>&1
  fi
}

install_nerd_font() {
  if font_present; then
    info "JetBrainsMono Nerd Font already installed."
    return
  fi
  local dir tmp
  case "$(uname -s)" in
    Darwin) dir="$HOME/Library/Fonts" ;;
    *)      dir="$HOME/.local/share/fonts/JetBrainsMono" ;;
  esac
  info "Installing JetBrainsMono Nerd Font -> $dir ..."
  mkdir -p "$dir"
  tmp="$(mktemp -d)"
  curl -fsSL "$FONT_ZIP_URL" -o "$tmp/JetBrainsMono.zip"
  unzip -oq "$tmp/JetBrainsMono.zip" -d "$dir" -x "*.md" "LICENSE"
  rm -rf "$tmp"
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$dir" >/dev/null 2>&1 || true
  info "Font installed. Set your terminal font to 'JetBrainsMono Nerd Font'."
}

# ---------------------------------------------------------------------------
# 1. Install tools  (skip with SKIP_PACKAGES=1 on an already-provisioned box)
# ---------------------------------------------------------------------------
OS="$(uname -s)"
if [ "${SKIP_PACKAGES:-0}" = "1" ]; then
  info "SKIP_PACKAGES=1 — skipping tool installation."
else
case "$OS" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      info "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    info "Installing packages via Homebrew (brew bundle)..."
    brew bundle --file="$REPO_DIR/Brewfile"
    ;;
  Linux)
    info "Installing packages via apt..."
    sudo apt-get update
    sudo apt-get install -y tmux git ripgrep fd-find jq nodejs npm python3 python3-pip curl unzip fontconfig glow kitty zsh eza bat fzf zoxide
    warn "On Debian/Ubuntu, fd installs as 'fdfind'. Add an 'fd' alias/symlink for telescope."
    warn "On Debian/Ubuntu, bat installs as 'batcat' — the zshrc aliases around this automatically."
    warn "apt's neovim is often too old. Install neovim >= 0.11 from the official release,"
    warn "the unstable PPA, or Homebrew-on-Linux before using this config."
    ;;
  *)
    echo "Unsupported OS: $OS"; exit 1 ;;
esac
fi

# neovim version sanity check (config needs 0.11+)
if command -v nvim >/dev/null 2>&1; then
  ver="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  major="${ver%%.*}"; minor="${ver##*.}"
  if [ "$major" -eq 0 ] && [ "$minor" -lt 11 ]; then
    warn "Detected neovim $ver — this config requires 0.11+. Upgrade before launching."
  fi
fi

# ---------------------------------------------------------------------------
# 1b. Terminal font (runs even under SKIP_PACKAGES; idempotent)
# ---------------------------------------------------------------------------
install_nerd_font

# ---------------------------------------------------------------------------
# 2. Symlink configs (backing up any existing real files)
# ---------------------------------------------------------------------------
link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    warn "Backing up existing $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -s "$src" "$dest"
  info "Linked $dest -> $src"
}

chmod +x "$REPO_DIR/claude/statusline-command.sh"
chmod +x "$REPO_DIR/claude/notify-stop.sh"
chmod +x "$REPO_DIR/claude/tmux-goto-done.sh"
chmod +x "$REPO_DIR/codex/notify-hook.sh"

link "$REPO_DIR/nvim"                          "$HOME/.config/nvim"
link "$REPO_DIR/tmux/tmux.conf"                "$HOME/.tmux.conf"
link "$REPO_DIR/zsh/zshrc"                     "$HOME/.zshrc"
link "$REPO_DIR/codex/config.toml"             "$HOME/.codex/config.toml"
link "$REPO_DIR/codex/hooks.json"              "$HOME/.codex/hooks.json"
link "$REPO_DIR/codex/notify-hook.sh"          "$HOME/.codex/notify-hook.sh"
link "$REPO_DIR/codex/rules/default.rules"     "$HOME/.codex/rules/default.rules"
link "$REPO_DIR/claude/CLAUDE.md"              "$HOME/.codex/AGENTS.md"
link "$REPO_DIR/claude/settings.json"          "$HOME/.claude/settings.json"
link "$REPO_DIR/claude/CLAUDE.md"              "$HOME/.claude/CLAUDE.md"
link "$REPO_DIR/claude/statusline-command.sh"  "$HOME/.claude/statusline-command.sh"
link "$REPO_DIR/claude/notify-stop.sh"         "$HOME/.claude/notify-stop.sh"
link "$REPO_DIR/claude/tmux-goto-done.sh"      "$HOME/.claude/tmux-goto-done.sh"
link "$REPO_DIR/skills/handoff"                 "$HOME/.codex/skills/handoff"
link "$REPO_DIR/skills/handoff"                 "$HOME/.claude/skills/handoff"
link "$REPO_DIR/skills/ticket-close"            "$HOME/.codex/skills/ticket-close"
link "$REPO_DIR/skills/ticket-close"            "$HOME/.claude/skills/ticket-close"
link "$REPO_DIR/skills/hipaa-code-review"       "$HOME/.codex/skills/hipaa-code-review"
link "$REPO_DIR/skills/hipaa-code-review"       "$HOME/.claude/skills/hipaa-code-review"
link "$REPO_DIR/codex/agents/ticket-close/ticket_linear_context.toml" "$HOME/.codex/agents/ticket_linear_context.toml"
link "$REPO_DIR/codex/agents/ticket-close/ticket_slack_context.toml" "$HOME/.codex/agents/ticket_slack_context.toml"
link "$REPO_DIR/codex/agents/ticket-close/ticket_notion_context.toml" "$HOME/.codex/agents/ticket_notion_context.toml"
link "$REPO_DIR/codex/agents/ticket-close/ticket_granola_context.toml" "$HOME/.codex/agents/ticket_granola_context.toml"
link "$REPO_DIR/codex/agents/ticket-close/ticket_reproducer.toml" "$HOME/.codex/agents/ticket_reproducer.toml"
link "$REPO_DIR/codex/agents/ticket-close/ticket_fix_planner.toml" "$HOME/.codex/agents/ticket_fix_planner.toml"
link "$REPO_DIR/codex/agents/ticket-close/ticket_implementer.toml" "$HOME/.codex/agents/ticket_implementer.toml"
link "$REPO_DIR/codex/agents/ticket-close/ticket_security_reviewer.toml" "$HOME/.codex/agents/ticket_security_reviewer.toml"
link "$REPO_DIR/codex/agents/ticket-close/ticket_code_reviewer.toml" "$HOME/.codex/agents/ticket_code_reviewer.toml"
link "$REPO_DIR/codex/agents/ticket-close/ticket_hipaa_reviewer.toml" "$HOME/.codex/agents/ticket_hipaa_reviewer.toml"
link "$REPO_DIR/claude/agents/ticket-close"     "$HOME/.claude/agents/ticket-close"

# glow reads its config from os.UserConfigDir(), which differs by platform.
case "$OS" in
  Darwin) GLOW_CFG="$HOME/Library/Application Support/glow/glow.yml" ;;
  *)      GLOW_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/glow/glow.yml" ;;
esac
link "$REPO_DIR/glow/glow.yml"                 "$GLOW_CFG"

# kitty uses ~/.config/kitty on both macOS and Linux. The whole dir is linked
# so kitty.conf's relative `include current-theme.conf` keeps working.
link "$REPO_DIR/kitty"                         "${XDG_CONFIG_HOME:-$HOME/.config}/kitty"

# ---------------------------------------------------------------------------
# 2c. Make zsh the default login shell (if it isn't already)
# ---------------------------------------------------------------------------
if command -v zsh >/dev/null 2>&1; then
  zsh_path="$(command -v zsh)"
  current_shell="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
  if [ "$current_shell" != "$zsh_path" ]; then
    grep -qxF "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    info "Setting default shell to zsh ($zsh_path)..."
    chsh -s "$zsh_path" || warn "chsh failed — run 'chsh -s $zsh_path' yourself, then re-login."
  else
    info "Default shell is already zsh."
  fi
else
  warn "zsh not found — skipping default-shell change."
fi

# ---------------------------------------------------------------------------
# 3. Bootstrap neovim plugins headlessly
# ---------------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
  info "Installing neovim plugins (lazy.nvim sync)..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  info "Installing LSP servers & formatters (Mason)..."
  nvim --headless "+MasonInstall lua-language-server pyright ruff typescript-language-server stylua" +qa 2>/dev/null || true
fi

info "Done."
echo
echo "Next steps:"
echo "  - Set your terminal font to 'JetBrainsMono Nerd Font' so icons render."
echo "  - Start tmux (or reload with prefix + R if already running)."
echo "  - Open nvim; run :checkhealth if anything looks off."
