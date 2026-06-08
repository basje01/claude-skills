#!/usr/bin/env bash
# install-refresh-launchd.sh — install the weekly gbrain-skill-refresh launchd
# job on the Mac. Idempotent. Run on demand (NOT during refresh.sh).
set -e

PLIST_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/com.bas.gbrain-skill-refresh.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.bas.gbrain-skill-refresh.plist"

if [ ! -f "$PLIST_SRC" ]; then
  echo "FATAL: plist source missing at $PLIST_SRC" >&2
  exit 1
fi

mkdir -p "$HOME/Library/LaunchAgents"
cp "$PLIST_SRC" "$PLIST_DST"
chmod 644 "$PLIST_DST"

# Unload if already loaded (avoids "service already loaded" warnings on re-install)
launchctl bootout "gui/$(id -u)/com.bas.gbrain-skill-refresh" 2>/dev/null || true

# Load fresh
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST"

echo "✓ installed: $PLIST_DST"
echo
echo "verify:"
echo "  launchctl list | grep gbrain"
echo "  launchctl print gui/$(id -u)/com.bas.gbrain-skill-refresh | grep -E 'state|next'"
echo
echo "manual fire (any time):"
echo "  launchctl kickstart gui/$(id -u)/com.bas.gbrain-skill-refresh"
echo "  # or just: ~/.claude/skills/gbrain/refresh.sh"
echo
echo "uninstall:"
echo "  launchctl bootout gui/$(id -u)/com.bas.gbrain-skill-refresh && rm $PLIST_DST"
