#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "=== macOS Install Script ==="
echo ""

echo "==> Installing third-party tap packages via Brewfile..."
brew bundle --file="$DOTFILES_DIR/scripts/macos/Brewfile"

echo ""
echo "==> Initializing git-lfs..."
git lfs install 2>/dev/null || true

echo ""
echo "==> Grouping Mission Control windows by application..."
if [ "$(defaults read com.apple.dock expose-group-apps 2>/dev/null)" != "1" ]; then
    defaults write com.apple.dock expose-group-apps -bool true
    killall Dock
fi

echo ""
echo "==> Configuring Rex..."
defaults write com.superlogical.rex Workspace.animationStyle -string off
defaults write com.superlogical.rex Workspace.activePaneBorderTransition -string off
defaults write com.superlogical.rex Workspace.terminalPaddingColor -string background
defaults write com.superlogical.rex SUScheduledCheckInterval -int 86400
defaults write com.superlogical.rex SUAutomaticallyUpdate -bool false

echo ""
echo "==> Starting noTunes at login..."
if [ -d /Applications/noTunes.app ]; then
    if ! osascript -e 'tell application "System Events" to get the name of every login item' | grep -q noTunes; then
        osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/noTunes.app", hidden:true}' >/dev/null
    fi
else
    echo "    noTunes not found, skipping"
fi

echo ""
echo "==> Setting up the Rex config and the leaf plugin..."
REX_DIR="$HOME/.config/rex"
if [ -L "$REX_DIR" ]; then
    rm "$REX_DIR"
fi
mkdir -p "$REX_DIR"
if [ ! -f "$REX_DIR/init.lua" ]; then
    printf 'dofile("%s/configs/rex/init.lua")\n' "$DOTFILES_DIR" > "$REX_DIR/init.lua"
fi
LEAF_BIN="$(command -v leaf || mise which leaf 2>/dev/null || true)"
if [ -n "$LEAF_BIN" ]; then
    "$LEAF_BIN" rex install
else
    echo "    leaf not found, skipping"
fi

echo ""
echo "==> Setting default applications..."
if command -v duti >/dev/null 2>&1; then
    duti "$DOTFILES_DIR/configs/macos/duti"
else
    echo "    duti not found, skipping"
fi

echo ""
echo "==> NOTE: Set up opam for OCaml development (needed for ocaml-lsp-server):"
echo "    opam init"
echo "    opam switch create 5.3.0"
echo '    eval $(opam env)'
echo "    Then run :MasonInstall ocaml-lsp-server in Neovim."
echo ""
echo "=== macOS Install Complete! ==="
