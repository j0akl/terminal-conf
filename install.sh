#!/usr/bin/env bash
# Install Jake's terminal config (tmux + neovim + claude) on a fresh machine.
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
    sudo apt-get install -y tmux git ripgrep fd-find jq nodejs npm python3 python3-pip curl unzip fontconfig glow kitty
    warn "On Debian/Ubuntu, fd installs as 'fdfind'. Add an 'fd' alias/symlink for telescope."
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

link "$REPO_DIR/nvim"                          "$HOME/.config/nvim"
link "$REPO_DIR/tmux/tmux.conf"                "$HOME/.tmux.conf"
link "$REPO_DIR/claude/settings.json"          "$HOME/.claude/settings.json"
link "$REPO_DIR/claude/statusline-command.sh"  "$HOME/.claude/statusline-command.sh"

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
