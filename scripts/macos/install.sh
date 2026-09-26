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

# wt-herdr is a worktrunk subcommand, not a herdr plugin, so it is not in plugins.txt
if [ ! -x "$HOME/.local/bin/wt-herdr" ]; then
    echo ""
    echo "==> Installing wt-herdr (worktrunk <-> herdr bridge)..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://raw.githubusercontent.com/mattarau/wt-herdr/main/wt-herdr \
        -o "$HOME/.local/bin/wt-herdr" && chmod +x "$HOME/.local/bin/wt-herdr"
fi

echo ""
echo "==> Grouping Mission Control windows by application..."
if [ "$(defaults read com.apple.dock expose-group-apps 2>/dev/null)" != "1" ]; then
    defaults write com.apple.dock expose-group-apps -bool true
    killall Dock
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
