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
failed=0

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
    if ! herdr plugin install "$repo" --yes; then
        echo "  FAILED: $repo" >&2
        failed=1
    fi
done < "$PLUGINS_FILE"

herdr server reload-config >/dev/null 2>&1 || true
echo "  Run 'herdr plugin list' to confirm"
exit "$failed"
