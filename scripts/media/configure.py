#!/usr/bin/env python3
"""Connect the services without printing or checking secrets into Git."""
import http.cookiejar
import json
import pathlib
import re
import secrets
import subprocess
import time
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

root = pathlib.Path('/srv/media/config')
credentials = root / 'credentials.json'
if credentials.exists():
    creds = json.loads(credentials.read_text())
else:
    creds = {name: secrets.token_urlsafe(24) for name in ('seedstrem', 'qbittorrent', 'prowlarr')}
    credentials.write_text(json.dumps(creds, indent=2) + '\n')
    credentials.chmod(0o600)

if 'prowlarr' not in creds:
    creds['prowlarr'] = secrets.token_urlsafe(24)
    credentials.write_text(json.dumps(creds, indent=2) + '\n')

cookies = http.cookiejar.CookieJar()
client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookies))

def post(path, fields):
    data = urllib.parse.urlencode(fields).encode()
    request = urllib.request.Request('http://127.0.0.1:8080' + path, data,
        headers={'Referer': 'http://127.0.0.1:8080', 'Origin': 'http://127.0.0.1:8080'})
    with client.open(request, timeout=10) as response:
        body = response.read()
        # Accept both successful API responses: HTTP 204 or 200 with Ok.
        if path == '/api/v2/auth/login' and response.status == 204:
            return b'Ok.'
        return body

for attempt in range(90):
    try:
        qbit_config = root / 'qbittorrent/qBittorrent/qBittorrent.conf'
        configured = qbit_config.exists() and 'Password_PBKDF2' in qbit_config.read_text()
        password = creds['qbittorrent']
        if not configured:
            logs = subprocess.check_output(['docker', 'compose', 'logs', '--no-color', 'qbittorrent']).decode()
            matches = re.findall(r'temporary password[^\n]*:\s*(\S+)', logs, re.I)
            if not matches:
                raise RuntimeError('Waiting for the initial qBittorrent password')
            password = matches[-1]
        response = post('/api/v2/auth/login', {'username': 'admin', 'password': password})
        if response != b'Ok.':
            raise RuntimeError('qBittorrent login failed; credentials may have been changed manually')
        post('/api/v2/app/setPreferences', {'json': json.dumps({
            'web_ui_password': creds['qbittorrent'], 'save_path': '/downloads/',
            'max_active_downloads': 2, 'max_active_torrents': 20,
            'max_active_uploads': 20, 'queueing_enabled': True,
            'upnp': False, 'dl_limit': 0, 'up_limit': 10000000,
        })})
        break
    except Exception:
        if attempt == 89:
            raise
        time.sleep(2)

for attempt in range(90):
    try:
        api_key = ET.parse(root / 'prowlarr/config.xml').getroot().findtext('ApiKey')
        if not api_key:
            raise RuntimeError('Waiting for Prowlarr API key')
        break
    except (OSError, ET.ParseError, RuntimeError):
        if attempt == 89:
            raise
        time.sleep(2)

# Set a separate Prowlarr UI password on first installation. Preserve later changes.
request = urllib.request.Request('http://127.0.0.1:9696/api/v1/config/host',
    headers={'X-Api-Key': api_key})
with urllib.request.urlopen(request, timeout=10) as response:
    host_config = json.load(response)
if host_config['authenticationMethod'] == 'none':
    host_config.update(authenticationMethod='forms', authenticationRequired='enabled',
        username='admin', password=creds['prowlarr'], passwordConfirmation=creds['prowlarr'],
        analyticsEnabled=False, updateAutomatically=False)
    request = urllib.request.Request('http://127.0.0.1:9696/api/v1/config/host',
        json.dumps(host_config).encode(), method='PUT',
        headers={'X-Api-Key': api_key, 'Content-Type': 'application/json'})
    with urllib.request.urlopen(request, timeout=10) as response:
        response.read()

# JSON is valid YAML. On later deployments preserve the settings edited in the UI.
config_file = root / 'seedstrem/config.yaml'
if not config_file.exists():
    config = {
        'server': {'listen': ':8080', 'external_url': pathlib.Path('/opt/media/external-url').read_text().strip(),
                   'admin_password': creds['seedstrem']},
        'qbittorrent': {'url': 'http://qbittorrent:8080', 'username': 'admin',
                        'password': creds['qbittorrent'], 'category': 'seedstrem'},
        'prowlarr': {'url': 'http://prowlarr:9696', 'api_key': api_key},
        'paths': {'mappings': [{'remote': '/downloads', 'local': '/data'}]},
        'storage': {'database': '/config/seedstrem.db', 'delete_files_on_remove': True,
                    'max_disk_usage_percent': 80},
        'cleanup': {'seed_time': '0s', 'target_ratio': 0, 'min_progress_for_cancel': 0},
        'filters': {'min_seeders': 1, 'max_size_mb': 51200, 'max_results': 20},
        'seeding': {'full': True}, 'rss': {'enabled': False},
    }
    config_file.write_text(json.dumps(config, indent=2) + '\n')
    config_file.chmod(0o600)
    import os
    os.chown(config_file, 1000, 1000)
print('Service connections configured. FileList credentials must be added in Prowlarr.')
