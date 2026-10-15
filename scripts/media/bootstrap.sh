#!/usr/bin/env bash
set -euo pipefail
cd /opt/media
if ! command -v docker >/dev/null; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y --no-install-recommends docker.io docker-compose-v2 git ca-certificates curl python3
fi
systemctl enable --now docker
if [[ ! -d /opt/seedstrem-source/.git ]]; then
    git clone https://github.com/kipsilabs/seedstrem.git /opt/seedstrem-source
fi
git -C /opt/seedstrem-source fetch origin dd04439e1b3ce0731168feb2b92a2bb66ca94718
git -C /opt/seedstrem-source checkout --detach dd04439e1b3ce0731168feb2b92a2bb66ca94718
# Keep local fixes explicit and idempotent on the pinned upstream revision.
for patch in /opt/media/patches/*.patch; do
    [[ -f "$patch" ]] || continue
    if git -C /opt/seedstrem-source apply --reverse --check "$patch" 2>/dev/null; then
        continue
    fi
    git -C /opt/seedstrem-source apply --check "$patch"
    git -C /opt/seedstrem-source apply "$patch"
done
install -d -m 700 /srv/media/config
install -d -o 1000 -g 1000 /srv/media/downloads /srv/media/config/{qbittorrent,prowlarr,seedstrem}
# Resolve registry tags on initial installation, then reuse the saved digests.
if [[ ! -e images.lock.yaml ]]; then
    docker compose pull qbittorrent prowlarr
    python3 - <<'PY'
import json, subprocess
services = {}
for service in ('qbittorrent', 'prowlarr'):
    tag = 'lscr.io/linuxserver/' + service + ':latest'
    info = json.loads(subprocess.check_output(['docker', 'image', 'inspect', tag]))[0]
    services[service] = {'image': info['RepoDigests'][0]}
with open('images.lock.yaml', 'w') as f:
    json.dump({'services': services}, f, indent=2)
PY
fi
docker compose -f compose.yaml -f images.lock.yaml up -d qbittorrent prowlarr
python3 configure.py
docker compose -f compose.yaml -f images.lock.yaml build seedstrem
compose_files=(-f compose.yaml -f images.lock.yaml)
if [[ -f public-compose.yaml ]]; then compose_files+=(-f public-compose.yaml); fi
docker compose "${compose_files[@]}" up -d
if [[ -f public-compose.yaml ]]; then
    docker compose "${compose_files[@]}" exec -T public-gateway nginx -s reload
fi
