# Jake's Terminal Config

Portable config for **zsh**, **tmux**, **neovim**, and **Claude Code**. Clone,
run one script, and a fresh machine (macOS or Linux) is set up the way I like it.

## Quick start

```sh
git clone <this-repo-url> ~/dev/terminal-config
cd ~/dev/terminal-config
./install.sh
```

`install.sh` will:

1. Install the required tools (Homebrew on macOS, apt on Linux).
2. Install JetBrainsMono Nerd Font (both platforms; skipped if already present).
3. Symlink the configs into place, backing up anything already there to `*.bak`.
4. Bootstrap neovim plugins (lazy.nvim) and LSP servers/formatters (Mason).

The installer also installs **JetBrainsMono Nerd Font** (macOS + Linux) — set
your terminal font to it so neovim's icons render.

Re-running on a machine that already has the tools? Skip the package step:

```sh
SKIP_PACKAGES=1 ./install.sh
```

## What's inside

```
zsh/      -> ~/.zshrc             zsh config (aliases, fzf/zoxide, git-aware prompt)
nvim/     -> ~/.config/nvim        neovim config (lazy.nvim + LSP + cmp)
tmux/     -> ~/.tmux.conf          tmux config
kitty/    -> ~/.config/kitty       kitty terminal config (JetBrainsMono NF, Rosé Pine theme)
claude/   -> ~/.claude/            Claude Code CLAUDE.md (global instructions), settings.json, statusline
glow/     -> glow.yml (*)          glow terminal markdown renderer config
Brewfile                           macOS packages (brew bundle)
install.sh                         installer / symlinker / bootstrapper
```

The configs are **symlinked**, not copied — edit them in place and the changes
show up here, ready to `git commit`.

(*) glow's config path is platform-specific (`os.UserConfigDir()`), so the
installer symlinks it to `~/.config/glow/glow.yml` on Linux and
`~/Library/Application Support/glow/glow.yml` on macOS.

## Tools required

| Tool | Why |
|------|-----|
| neovim **0.11+** | editor (config uses the 0.11 `vim.lsp` API) |
| kitty | terminal emulator (config in `kitty/`) |
| tmux | terminal multiplexer / panes |
| ripgrep (`rg`) | telescope live-grep |
| fd | telescope file finding |
| jq | Claude Code statusline script |
| node | pyright + typescript-language-server (via Mason), prettier |
| python | ruff (via Mason) |
| glow | render markdown in the terminal (`glow file.md`) |
| zsh | login shell (`zsh/zshrc`); installer sets it as default via `chsh` |
| eza | modern `ls` — aliased to `ls`, plus `ll` (`eza -alh`) |
| bat | modern `cat` with syntax highlighting — aliased to `cat` (`batcat` on Debian/Ubuntu) |
| fzf | fuzzy finder — `Ctrl-R` history, `Ctrl-T` files, `Alt-C` cd |
| zoxide | smarter `cd` — `z <partial-dir>` jumps to frequent dirs |

Language servers (`pyright`, `ruff`, `ts_ls`, `lua_ls`) and formatters
(`stylua`) are installed by **Mason** inside neovim — no manual install needed.

## Highlights

**neovim** — autocomplete (nvim-cmp + LSP), treesitter highlighting,
telescope, nvim-tree, gitsigns, diffview, conform (format-on-save with
ruff/prettier), render-markdown, rainbow brackets, rose-pine theme.

- `<leader>` is `Space`.
- `<leader>ff` / `<leader>fg` — find files / live grep
- `<leader>e` — file tree
- `<leader>gd` — diff working changes (review edits) · `<leader>gh` — file history
- `<leader>uc` — pick colorscheme (live preview)
- `gd` `gr` `K` `<leader>ca` `<leader>rn` — LSP: definition, refs, hover, code action, rename
- format-on-save is automatic; `<leader>cf` formats manually

**zsh** — shared history, case-insensitive completion, a git-aware prompt, and
`ls`/`ll`/`cat` aliased to eza/bat. fzf key-bindings (`Ctrl-R`/`Ctrl-T`/`Alt-C`)
and zoxide (`z <dir>`) are wired up when those tools are present.

**tmux** — `C-a` prefix, vim-style splits/navigation, labeled pane header bars
with heavy borders so panes are easy to tell apart. `prefix + R` reloads.

**Claude Code** — `dark-daltonized` theme, `opus` model, and a custom
statusline showing `user@host:cwd`, git branch + dirty marker, and the model.

## Notes / gotchas

- **Debian/Ubuntu**: `fd` is installed as `fdfind`; symlink it to `fd` for
  telescope. `bat` is installed as `batcat` (the zshrc aliases around this).
  apt's neovim is usually too old — install 0.11+ separately.
- First neovim launch after install may briefly download treesitter parsers.
- Plugin versions are pinned in `nvim/lazy-lock.json` for reproducible installs.
  Run `:Lazy update` in neovim to bump them, then commit the lockfile.
