#!/usr/bin/env python3
"""Generate the public URL credential and point Seedstrem at the gateway."""
import http.cookiejar
import json
import pathlib
import secrets
import sys
import urllib.request

root = pathlib.Path('/srv/media/config')
creds_file = root / 'credentials.json'
creds = json.loads(creds_file.read_text())
creds.setdefault('public_token', secrets.token_urlsafe(32))
origin = sys.argv[1].rstrip('/') if sys.argv[1].startswith('https://') else 'https://' + sys.argv[1]
base = origin + '/' + creds['public_token']
creds['public_manifest_url'] = base + '/stremio/manifest.json'
creds_file.write_text(json.dumps(creds, indent=2) + '\n')
creds_file.chmod(0o600)
public_dir = root / 'public'
public_dir.mkdir(mode=0o700, exist_ok=True)
template = pathlib.Path('/opt/media/public-nginx.conf').read_text()
conf = public_dir / 'nginx.conf'
conf.write_text(template.replace('__TOKEN__', creds['public_token']))
conf.chmod(0o600)

if '--activate' in sys.argv[2:]:
    client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
    headers = {'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest'}
    api = 'http://127.0.0.1:8081/api/'
    client.open(urllib.request.Request(api + 'session',
        json.dumps({'password': creds['seedstrem']}).encode(), headers=headers), timeout=10).read()
    config = json.load(client.open(api + 'config', timeout=10))
    config['server']['external_url'] = base
    client.open(urllib.request.Request(api + 'config', json.dumps(config).encode(),
        method='PUT', headers=headers), timeout=10).read()
    creds['public_enabled'] = True
    creds['public_origin'] = origin
    creds_file.write_text(json.dumps(creds, indent=2) + '\n')
print('Public streaming credential generated; admin routes are excluded from the gateway.')
