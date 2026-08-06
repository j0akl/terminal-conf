#!/bin/sh
# Give Claude Code one stable macOS identity across auto-updates.
#
# The native installer parks each release at ~/.local/share/claude/versions/<ver>
# and repoints ~/.local/bin/claude at it. macOS keys TCC (Privacy & Security) and
# Keychain grants for a bare, non-bundled binary to its absolute path -- so every
# update is a brand-new program named after the version, and Desktop / Documents /
# Downloads / local network / keychain all re-prompt. Hence the pile of "2.1.x"
# rows in System Settings.
#
# Claude Code already ships ClaudeCode.app (bundle id com.anthropic.claude-code)
# and hard-links the running binary into it so its background PTY host gets a fixed
# identity. This wrapper extends that to the foreground process: point the bundle's
# hard link at whichever version is current, then exec from the bundle's unchanging
# path. macOS sees one client, named "Claude Code", forever.
#
# Falls through to the real binary on any problem -- a launcher must never be the
# reason claude won't start.

claude_home="$HOME/.local/share/claude"
app_dir="$claude_home/ClaudeCode.app"
app_macos="$app_dir/Contents/MacOS"
app_bin="$app_macos/claude"
installed="$HOME/.local/bin/claude"

target=$(readlink -f "$installed" 2>/dev/null)
[ -n "$target" ] || target="$installed"

# Escape hatch: CLAUDE_SHIM_BYPASS=1 claude ... runs the versioned binary
# directly, in case routing through the bundle ever misbehaves.
if [ -n "${CLAUDE_SHIM_BYPASS:-}" ]; then
    exec "$target" "$@"
fi

# Only versioned native installs have the churn problem. An npm, Homebrew, or
# hand-placed claude already lives at a stable path -- run it untouched.
case "$target" in
    "$claude_home"/versions/*) ;;
    *) exec "$target" "$@" ;;
esac

want=$(stat -f %i "$target" 2>/dev/null)
have=$(stat -f %i "$app_bin" 2>/dev/null)

if [ -n "$want" ] && [ "$want" != "$have" ]; then
    # Hard link, so this shares the inode with versions/<ver>: no extra disk, and
    # any process already running out of the bundle keeps its own inode alive.
    if mkdir -p "$app_macos" 2>/dev/null; then
        if [ ! -f "$app_dir/Contents/Info.plist" ]; then
            # Same plist Claude Code writes for itself; the usage strings are what
            # let macOS prompt for mic, Apple Events, and local network by name.
            cat > "$app_dir/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>CFBundleIdentifier</key><string>com.anthropic.claude-code</string><key>CFBundleName</key><string>Claude Code</string><key>CFBundleDisplayName</key><string>Claude Code</string><key>CFBundleExecutable</key><string>claude</string><key>CFBundlePackageType</key><string>APPL</string><key>LSUIElement</key><true/><key>NSMicrophoneUsageDescription</key><string>Claude Code uses the microphone for voice dictation.</string><key>NSAppleEventsUsageDescription</key><string>Claude Code needs to send Apple Events to open URLs and control applications you authorize.</string><key>NSLocalNetworkUsageDescription</key><string>Claude Code connects to servers and devices on your local network when commands you run need to reach them.</string></dict></plist>
PLIST
        fi
        rm -f "$app_bin" 2>/dev/null
        ln "$target" "$app_bin" 2>/dev/null
    fi
fi

[ -x "$app_bin" ] && exec "$app_bin" "$@"
exec "$target" "$@"
