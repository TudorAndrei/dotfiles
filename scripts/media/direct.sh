#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ssh_args=(-F "$HOME/.ssh/config" nixos-laptop)
# Caddy and the firewall are declared in media-public.nix. Configure router
# forwarding before running this, so public ACME validation can succeed.
"$repo/nix/hosts/nixos-laptop/deploy"
tar -C "$repo" -cf - configs/media/public-nginx.conf configs/media/public-compose.yaml scripts/media/public-configure.py |
    ssh "${ssh_args[@]}" 'sudo mkdir -p /var/lib/dotfiles-media; sudo tar -C /var/lib/dotfiles-media -xf -'
ssh "${ssh_args[@]}" 'sudo bash -s' <<'REMOTE'
set -euo pipefail
for file in public-nginx.conf public-compose.yaml; do
    incus file push "/var/lib/dotfiles-media/configs/media/$file" "media/opt/media/$file"
done
incus file push /var/lib/dotfiles-media/scripts/media/public-configure.py media/opt/media/public-configure.py
incus exec media -- python3 /opt/media/public-configure.py https://casapuiu.home.ro < /dev/null
if ! incus config device get media public-gateway listen >/dev/null 2>&1; then
    incus config device add media public-gateway proxy listen=tcp:127.0.0.1:8082 connect=tcp:127.0.0.1:8082
fi
incus exec media -- bash -c 'cd /opt/media; docker compose -f compose.yaml -f images.lock.yaml -f public-compose.yaml up -d public-gateway; docker compose -f compose.yaml -f images.lock.yaml -f public-compose.yaml exec -T public-gateway nginx -t; docker compose -f compose.yaml -f images.lock.yaml -f public-compose.yaml exec -T public-gateway nginx -s reload' < /dev/null
# Validate the public certificate and keyed gateway via the host LAN address.
# A missing key must return 404, rather than exposing the administration UI.
status=$(curl --max-time 30 --resolve casapuiu.home.ro:443:192.168.0.244 -sS -o /dev/null -w '%{http_code}' https://casapuiu.home.ro/)
[[ "$status" == 404 ]] || { echo "Direct HTTPS is not ready (expected gateway 404, got $status)." >&2; exit 1; }
incus exec media -- python3 /opt/media/public-configure.py https://casapuiu.home.ro --activate < /dev/null
echo "Direct HTTPS configured. Retrieve public_manifest_url from the guest credentials file."
REMOTE
