#!/usr/bin/env bash
set -e

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo -E"
fi

echo "=== Debian/Ubuntu Install Script ==="
echo ""

echo "==> Silencing the login MOTD..."
touch "$HOME/.hushlogin"

echo ""
echo "==> Initializing git-lfs..."
git lfs install 2>/dev/null || true

echo ""
echo "==> Setting up tmux tpm..."
mkdir -p "$HOME/.tmux/plugins"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    git -C "$HOME/.tmux/plugins/tpm" pull --ff-only 2>/dev/null || true
fi

if [ ! -x "$HOME/.local/bin/wt-herdr" ]; then
    echo ""
    echo "==> Installing wt-herdr (worktrunk <-> herdr bridge)..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://raw.githubusercontent.com/mattarau/wt-herdr/main/wt-herdr \
        -o "$HOME/.local/bin/wt-herdr" && chmod +x "$HOME/.local/bin/wt-herdr"
fi

ZSH_BIN="$(command -v zsh || true)"
if [ -n "$ZSH_BIN" ] && [ "$SHELL" != "$ZSH_BIN" ]; then
    echo ""
    echo "==> Setting default shell to Zsh..."
    grep -qx "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | $SUDO tee -a /etc/shells >/dev/null
    if ! $SUDO chsh -s "$ZSH_BIN" "$(id -un)"; then
        echo "  WARNING: chsh failed; run 'chsh -s $ZSH_BIN' manually"
    fi
fi

echo ""
echo "=== Debian/Ubuntu Install Complete! ==="
