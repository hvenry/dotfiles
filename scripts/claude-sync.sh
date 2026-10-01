#!/bin/bash
# Install whatever Claude Code plugins this machine is missing, from the tracked manifest:
# enabledPlugins + extraKnownMarketplaces in shared/claude/.claude/settings.json.
# Idempotent: already-installed items are skipped. Safe to re-run any time.
#
# Personal-only items (MCP plugins that send data to personal accounts, third-party
# marketplaces) install only on machines that opt in with:
#   mkdir -p ~/.config/dotfiles && touch ~/.config/dotfiles/personal
# Without that marker (e.g. a work machine) they stay uninstalled, so they never
# load even though settings.json lists them; /plugin shows them as "not cached".
set -u

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS="$DOTFILES_DIR/shared/claude/.claude/settings.json"

PERSONAL_PLUGINS="
notion@claude-plugins-official
figma@claude-plugins-official
railway@claude-plugins-official
expo@expo-plugins
"
PERSONAL_MARKETPLACES="expo-plugins"

if [ -e "$HOME/.config/dotfiles/personal" ]; then
  PERSONAL=true
else
  PERSONAL=false
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "claude is not installed - skipping Claude sync"
  exit 0
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed - skipping Claude sync"
  exit 0
fi

is_personal() { grep -qx "$1" <<<"$2"; }

sync_marketplaces() {
  local have name repo
  have="$(claude plugin marketplace list --json 2>/dev/null | jq -r '.[].name')"
  jq -r '.extraKnownMarketplaces // {} | to_entries[]
    | select(.value.source.source == "github")
    | "\(.key) \(.value.source.repo)"' "$SETTINGS" |
    while read -r name repo; do
      if [ "$PERSONAL" = false ] && is_personal "$name" "$PERSONAL_MARKETPLACES"; then
        echo "  marketplace $name: personal only, skipped"
      elif grep -qx "$name" <<<"$have"; then
        echo "  marketplace $name: ok"
      else
        echo "  marketplace $name: adding $repo"
        claude plugin marketplace add "$repo" || echo "  failed to add $repo"
      fi
    done
}

sync_plugins() {
  local have id
  have="$(claude plugin list --json 2>/dev/null | jq -r '.[].id')"
  jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$SETTINGS" |
    while read -r id; do
      if [ "$PERSONAL" = false ] && is_personal "$id" "$PERSONAL_PLUGINS"; then
        echo "  plugin $id: personal only, skipped"
      elif grep -qx "$id" <<<"$have"; then
        echo "  plugin $id: ok"
      else
        echo "  plugin $id: installing"
        claude plugin install "$id" </dev/null || echo "  failed to install $id"
      fi
    done
}

echo "Syncing Claude Code plugins ($([ "$PERSONAL" = true ] && echo personal || echo default) machine)..."
sync_marketplaces
sync_plugins
