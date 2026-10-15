#!/usr/bin/env bash
set -euo pipefail
cd /opt/cliproxy
if ! command -v docker >/dev/null; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y --no-install-recommends docker.io docker-compose-v2 ca-certificates openssl
fi
systemctl enable --now docker
install -d -m 700 /srv/cliproxy /srv/cliproxy/auths /srv/cliproxy/logs
if [[ ! -f /srv/cliproxy/config.yaml ]]; then
    key=$(openssl rand -hex 32)
    umask 077
    cat > /srv/cliproxy/config.yaml <<CONFIG
config-version: 8
server:
  host: "127.0.0.1"
  port: 8317
management:
  allow-remote: false
  secret-key: ""
  disable-control-panel: true
routing:
  session-affinity: true
access:
  api-keys:
    - "$key"
oauth:
  auth-dir: "/root/.cli-proxy-api"
CONFIG
fi
docker compose -f compose.yaml pull
docker compose -f compose.yaml up -d
