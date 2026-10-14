#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ssh_args=(-F "$HOME/.ssh/config" nixos-laptop)
# Use the host's existing Incus pool; do not alter partitions or host drivers.
ssh "${ssh_args[@]}" 'sudo bash -s' <<'REMOTE'
set -euo pipefail
if ! incus info media >/dev/null 2>&1; then
    incus init images:ubuntu/24.04 media -c security.nesting=true \
      -c security.syscalls.intercept.mknod=true -c security.syscalls.intercept.setxattr=true \
      -c limits.cpu=4 -c limits.memory=4GiB -c user.dotfiles=media
fi
[[ "$(incus config get media user.dotfiles)" == media ]] || { echo "Unmanaged media instance exists; refusing to change it." >&2; exit 1; }
if ! incus storage volume show default media-data >/dev/null 2>&1; then
    incus storage volume create default media-data size=200GiB
fi
if ! incus config device get media data source >/dev/null 2>&1; then
    incus config device add media data disk pool=default source=media-data path=/srv/media
fi
if [[ "$(incus list media --format csv -c s)" == STOPPED ]]; then incus start media; fi
incus exec media -- mkdir -p /opt/media < /dev/null
REMOTE
# Transfer only configuration and installers; secrets stay in the guest.
tar -C "$repo" -cf - configs/media/compose.yaml configs/media/images.lock.yaml scripts/media/bootstrap.sh scripts/media/configure.py configs/media/patches |
    ssh "${ssh_args[@]}" 'sudo mkdir -p /var/lib/dotfiles-media; sudo tar -C /var/lib/dotfiles-media -xf -'
ssh "${ssh_args[@]}" 'sudo bash -s' <<'REMOTE'
set -euo pipefail
for item in compose.yaml images.lock.yaml bootstrap.sh configure.py; do
    source=/var/lib/dotfiles-media/scripts/media/$item
    [[ "$item" != compose.yaml && "$item" != images.lock.yaml ]] || source=/var/lib/dotfiles-media/configs/media/$item
    incus file push "$source" "media/opt/media/$item"
done
incus exec media -- mkdir -p /opt/media/patches < /dev/null
for patch in /var/lib/dotfiles-media/configs/media/patches/*.patch; do
    incus file push "$patch" "media/opt/media/patches/$(basename "$patch")"
done
# Native Stremio clients can use the private Tailscale HTTP endpoint.
ip=$(tailscale ip -4)
printf 'http://%s:8081\n' "$ip" > /var/lib/dotfiles-media/external-url
incus file push /var/lib/dotfiles-media/external-url media/opt/media/external-url
for mapping in 'seedstrem 8081 8081 0.0.0.0' 'qbittorrent 8080 8080 127.0.0.1' 'prowlarr 9696 9696 127.0.0.1'; do
    read -r name port target address <<< "$mapping"
    if ! incus config device get media "$name" listen >/dev/null 2>&1; then
        incus config device add media "$name" proxy listen="tcp:$address:$port" connect="tcp:127.0.0.1:$target"
    fi
done
incus exec media -- bash /opt/media/bootstrap.sh < /dev/null
REMOTE
