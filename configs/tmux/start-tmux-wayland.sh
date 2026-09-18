#!/usr/bin/env bash
set -euo pipefail

while IFS='=' read -r key value; do
    case "$key" in
        WAYLAND_DISPLAY|DISPLAY|HYPRLAND_INSTANCE_SIGNATURE|XDG_CURRENT_DESKTOP|XDG_SESSION_TYPE|OZONE_PLATFORM_HINT|OZONE_PLATFORM|ELECTRON_OZONE_PLATFORM_HINT)
            export "$key=$value"
            ;;
    esac
done < <(systemctl --user show-environment 2>/dev/null || true)

exec tmux new-session -d
