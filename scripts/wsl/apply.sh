#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if ! [[ "$(uname -r)" == *microsoft* ]]; then
    echo "This configuration is for the Ubuntu WSL management machine." >&2
    exit 1
fi

if [[ "${1:-}" == --system ]]; then
    [[ "$(id -u)" -eq 0 ]] || { echo "System configuration requires root." >&2; exit 1; }
    # Back up the original once. Keep system config as root-owned copies.
    if [[ ! -e /etc/nix/nix.custom.conf.before-dotfiles-wsl ]]; then
        cp -a /etc/nix/nix.custom.conf /etc/nix/nix.custom.conf.before-dotfiles-wsl
    fi
    install -m 644 "$repo/nix/nix.custom.conf" /etc/nix/nix.custom.conf
    install -d /etc/systemd/system/nix-daemon.service.d
    install -m 644 "$repo/configs/wsl/nix-daemon.conf" /etc/systemd/system/nix-daemon.service.d/20-dotfiles.conf
    systemctl daemon-reload
    systemctl restart nix-daemon.service
    exit 0
fi

# Resolve the Windows profile instead of hard-coding a Windows username.
profile="$(powershell.exe -NoProfile -NonInteractive -Command '[Console]::Write($env:USERPROFILE)' | tr -d '\r')"
target="$(wslpath "$profile")/.wslconfig"
if [[ -e "$target" ]] && ! cmp -s "$repo/configs/wsl/wslconfig" "$target"; then
    backup="${target}.before-dotfiles-$(date +%Y%m%d-%H%M%S)"
    cp -p "$target" "$backup"
    echo "Previous Windows configuration saved to $backup"
fi
cp "$repo/configs/wsl/wslconfig" "$target"
wsl.exe -d "${WSL_DISTRO_NAME:?Run this script inside WSL}" -u root -- bash "$repo/scripts/wsl/apply.sh" --system
echo "Lix settings applied. After saving your work, run wsl --shutdown in Windows and reopen Ubuntu to apply .wslconfig."
