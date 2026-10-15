#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ssh_args=(-F "$HOME/.ssh/config" nixos-laptop)
tar -C "$repo" -cf - configs/media/public-nginx.conf configs/media/public-compose.yaml scripts/media/public-configure.py |
    ssh "${ssh_args[@]}" 'sudo mkdir -p /var/lib/dotfiles-media; sudo tar -C /var/lib/dotfiles-media -xf -'
ssh "${ssh_args[@]}" 'sudo bash -s' <<'REMOTE'
set -euo pipefail
for file in public-nginx.conf public-compose.yaml; do
    incus file push "/var/lib/dotfiles-media/configs/media/$file" "media/opt/media/$file"
done
incus file push /var/lib/dotfiles-media/scripts/media/public-configure.py media/opt/media/public-configure.py
domain=$(tailscale status --json | incus exec media -- python3 -c 'import sys,json; print(json.load(sys.stdin)["Self"]["DNSName"].rstrip("."))')
incus exec media -- python3 /opt/media/public-configure.py "$domain" < /dev/null
if ! incus config device get media public-gateway listen >/dev/null 2>&1; then
    incus config device add media public-gateway proxy listen=tcp:127.0.0.1:8082 connect=tcp:127.0.0.1:8082
fi
incus exec media -- bash -c 'cd /opt/media; docker compose -f compose.yaml -f images.lock.yaml -f public-compose.yaml up -d public-gateway; docker compose -f compose.yaml -f images.lock.yaml -f public-compose.yaml exec -T public-gateway nginx -t; docker compose -f compose.yaml -f images.lock.yaml -f public-compose.yaml exec -T public-gateway nginx -s reload' < /dev/null
# Funnel publishes only the authenticated gateway, never the raw app or admin ports.
timeout 20 tailscale serve --bg --https=9443 http://127.0.0.1:8081
timeout 20 tailscale funnel --bg --https=443 http://127.0.0.1:8082
tailscale funnel --https=10000 off || true
incus exec media -- python3 /opt/media/public-configure.py "$domain" --activate < /dev/null
REMOTE
