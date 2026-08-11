#!/bin/sh
# One stable PATH entry for Claude Code across auto-updates.
#
# This used to hard-link the versioned binary into
# ~/.local/share/claude/ClaudeCode.app and exec from there, so macOS would key TCC
# (Privacy & Security) and Keychain grants to a single bundle identity rather than
# to a brand-new ~/.local/share/claude/versions/<ver> path on every release --
# hence the pile of "2.1.x" rows in System Settings this was written to stop.
#
# Two reasons that is gone.
#
# Claude Code builds and maintains that bundle itself now: the binary carries the
# ClaudeCode.app and Contents/MacOS paths, and rewrites Contents/Info.plist during
# an ordinary run. This wrapper was racing upstream for ownership of a directory
# upstream already owns.
#
# And routing the FOREGROUND process through it is what broke launching. The CLI is
# signed as a standalone Mach-O -- "Sealed Resources=none", "Info.plist=not bound"
# -- which is a valid signature for a bare executable but not for a bundle. Once
# that binary sits at Contents/MacOS/claude inside a .app, macOS stops evaluating
# it as a binary and evaluates it as a bundle, finds no
# _CodeSignature/CodeResources, and both codesign --verify and spctl report:
#
#     code has no resources but signature indicates they must be present
#
# which macOS surfaces as "Claude Code couldn't be opened ... it is damaged ...
# move it to the Trash." Exec'ing the versioned binary directly never enters bundle
# evaluation, and its Developer ID signature (Anthropic PBC, Q6L2SF6YDW) validates
# on its own.
#
# What is left is the stable PATH entry and a place to put launcher logic if it is
# ever needed again. Falls through on any problem -- a launcher must never be the
# reason claude won't start.

installed="$HOME/.local/bin/claude"

target=$(readlink -f "$installed" 2>/dev/null)
[ -n "$target" ] || target="$installed"

exec "$target" "$@"
