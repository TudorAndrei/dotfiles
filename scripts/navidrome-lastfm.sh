#!/usr/bin/env bash
set -e

ITEM="${LASTFM_BW_ITEM:-Last.fm API}"
HOST="${NAVIDROME_HOST:-nixos-laptop}"
TARGET="/etc/navidrome/lastfm.env"

if [ -z "${BW_SESSION:-}" ]; then
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
fi

bw sync >/dev/null
item="$(bw get item "$ITEM")"
key="$(jq -r '.login.username // empty' <<<"$item")"
secret="$(jq -r '.login.password // empty' <<<"$item")"

if [ -z "$key" ] || [ -z "$secret" ]; then
  echo "Bitwarden item \"$ITEM\" needs the API key as username and the shared secret as password" >&2
  exit 1
fi

printf 'ND_LASTFM_APIKEY=%s\nND_LASTFM_SECRET=%s\n' "$key" "$secret" |
  ssh "$HOST" "sudo install -D -m 600 -o root -g root /dev/stdin $TARGET && sudo systemctl restart navidrome"

echo "==> Wrote $HOST:$TARGET and restarted Navidrome"
exit 0
