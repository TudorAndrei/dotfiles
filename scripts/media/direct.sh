#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ssh_args=(-F "$HOME/.ssh/config" nixos-laptop)
# Caddy and the firewall are declared in media-public.nix. Configure router
# forwarding before running this, so public ACME validation can succeed.
"$repo/nix/hosts/nixos-laptop/deploy"
scp -F "$HOME/.ssh/config" "$repo/scripts/media/public-configure.py" nixos-laptop:/tmp/media-public-configure.py
ssh "${ssh_args[@]}" 'sudo bash -s' <<'REMOTE'
set -euo pipefail
incus file push /tmp/media-public-configure.py media/opt/media/public-configure.py
# Validate the public certificate and keyed gateway via the host LAN address.
# A missing key must return 404, rather than exposing the administration UI.
status=$(curl --max-time 30 --resolve casapuiu.home.ro:443:192.168.0.244 -sS -o /dev/null -w '%{http_code}' https://casapuiu.home.ro/)
[[ "$status" == 404 ]] || { echo "Direct HTTPS is not ready (expected gateway 404, got $status)." >&2; exit 1; }
incus exec media -- python3 /opt/media/public-configure.py https://casapuiu.home.ro --activate < /dev/null
# Retain private administration; retire the unsuccessful public Funnel route.
tailscale funnel --https=443 off || true
tailscale funnel --https=10000 off || true
echo "Direct HTTPS configured. Retrieve public_manifest_url from the guest credentials file."
REMOTE
