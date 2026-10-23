#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ssh_args=(-F "$HOME/.ssh/config" nixos-laptop)
ssh "${ssh_args[@]}" 'sudo bash -s' <<'REMOTE'
set -euo pipefail
if ! incus info cliproxy >/dev/null 2>&1; then
    incus init images:ubuntu/24.04 cliproxy -c security.nesting=true \
      -c security.syscalls.intercept.mknod=true -c security.syscalls.intercept.setxattr=true \
      -c limits.cpu=2 -c limits.memory=1GiB -c boot.autostart=true -c user.dotfiles=cliproxy
fi
[[ "$(incus config get cliproxy user.dotfiles)" == cliproxy ]] || { echo "Unmanaged cliproxy instance exists; refusing to change it." >&2; exit 1; }
if [[ "$(incus list cliproxy --format csv -c s)" == STOPPED ]]; then incus start cliproxy; fi
if ! incus config device get cliproxy api listen >/dev/null 2>&1; then
    incus config device add cliproxy api proxy listen=tcp:0.0.0.0:8318 connect=tcp:127.0.0.1:8317
elif [[ "$(incus config device get cliproxy api listen)" != tcp:0.0.0.0:8318 ]]; then
    incus config device set cliproxy api listen=tcp:0.0.0.0:8318
fi
for port in 8085 1455 54545 51121 11451; do
    if ! incus config device get cliproxy "oauth-$port" listen >/dev/null 2>&1; then
        incus config device add cliproxy "oauth-$port" proxy "listen=tcp:127.0.0.1:$port" "connect=tcp:127.0.0.1:$port"
    fi
done
incus exec cliproxy -- mkdir -p /opt/cliproxy < /dev/null
REMOTE
tar -C "$repo" -cf - configs/cliproxy/compose.yaml scripts/cliproxy/bootstrap.sh |
    ssh "${ssh_args[@]}" 'sudo mkdir -p /var/lib/dotfiles-cliproxy; sudo tar -C /var/lib/dotfiles-cliproxy -xf -'
ssh "${ssh_args[@]}" 'sudo bash -s' <<'REMOTE'
set -euo pipefail
incus file push /var/lib/dotfiles-cliproxy/configs/cliproxy/compose.yaml cliproxy/opt/cliproxy/compose.yaml
incus file push /var/lib/dotfiles-cliproxy/scripts/cliproxy/bootstrap.sh cliproxy/opt/cliproxy/bootstrap.sh
incus exec cliproxy -- bash /opt/cliproxy/bootstrap.sh < /dev/null
REMOTE
echo "Retrieve the client key: ssh nixos-laptop 'sudo incus exec cliproxy -- cat /srv/cliproxy/config.yaml'"
echo 'Dashboard on the tailnet: http://100.121.29.45:8318/management.html'
