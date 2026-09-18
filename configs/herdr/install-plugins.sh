#!/usr/bin/env bash
set -e

PLUGINS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/plugins.txt"

UPDATE=0
[ "${1:-}" = "--update" ] && UPDATE=1

if ! command -v herdr >/dev/null 2>&1; then
    echo "  SKIP: herdr not installed"
    exit 0
fi

installed="$(herdr plugin list 2>/dev/null || true)"

while IFS= read -r repo; do
    case "$repo" in
        ''|\#*) continue ;;
    esac

    name="${repo##*/}"
    if [ "$UPDATE" -eq 0 ] && printf '%s\n' "$installed" | grep -qi "$name"; then
        echo "  Already installed: $repo"
        continue
    fi

    echo "==> Installing $repo"
    herdr plugin install "$repo" --yes || echo "  FAILED: $repo"
done < "$PLUGINS_FILE"

herdr server reload-config >/dev/null 2>&1 || true
echo "  Run 'herdr plugin list' to confirm"
