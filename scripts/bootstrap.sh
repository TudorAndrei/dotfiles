#!/usr/bin/env bash
set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

echo "=== Dotfiles Bootstrap ==="
echo ""

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "ERROR: $DOTFILES_DIR not found"
    exit 1
fi

if [ ! -x "$HOME/.local/bin/mise" ] && ! command -v mise >/dev/null 2>&1; then
    echo "==> Installing mise..."
    curl -fsSL https://mise.run | sh
fi

MISE="$(command -v mise || echo "$HOME/.local/bin/mise")"

cd "$DOTFILES_DIR"

echo "==> Trusting the dotfiles mise config..."
"$MISE" trust

echo "==> Installing just..."
if ! "$MISE" install just; then
    echo "==> WARNING: mise reported install errors; continuing"
fi

JUST="$("$MISE" which just 2>/dev/null || true)"
if [ -z "$JUST" ]; then
    echo "ERROR: just is not available"
    exit 1
fi

echo ""
"$JUST" bootstrap
