#!/usr/bin/env bash
set -euo pipefail
# The account owner must first enable Serve on the tailnet. Funnel is unnecessary.
ssh -F "$HOME/.ssh/config" nixos-laptop 'sudo bash -s' <<'REMOTE'
set -euo pipefail
timeout 20 tailscale serve --bg --https=443 http://127.0.0.1:8081
timeout 20 tailscale serve --bg --https=8443 http://127.0.0.1:9696
timeout 20 tailscale serve --bg --https=8444 http://127.0.0.1:8080
domain=$(tailscale status --json | incus exec media -- python3 -c 'import sys,json; print(json.load(sys.stdin)["Self"]["DNSName"].rstrip("."))')
incus exec media -- python3 - "$domain" <<'PY'
import http.cookiejar, json, pathlib, sys, urllib.request
root = pathlib.Path('/srv/media/config')
creds = json.loads((root / 'credentials.json').read_text())
client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
base = 'http://127.0.0.1:8081/api/'
request = urllib.request.Request(base + 'session', json.dumps({'password': creds['seedstrem']}).encode(),
                                 headers={'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest'})
client.open(request, timeout=10).read()
config = json.load(client.open(base + 'config', timeout=10))
config['server']['external_url'] = 'https://' + sys.argv[1]
request = urllib.request.Request(base + 'config', json.dumps(config).encode(), method='PUT',
                                 headers={'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest'})
client.open(request, timeout=10).read()
print('Stremio manifest: https://' + sys.argv[1] + '/stremio/manifest.json')
print('Prowlarr: https://' + sys.argv[1] + ':8443')
print('qBittorrent: https://' + sys.argv[1] + ':8444')
PY
REMOTE
