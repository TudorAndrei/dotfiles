#!/usr/bin/env bash
set -e

ITEM="${HERMES_BW_ITEM:-Hermes}"
HOST="${HERMES_HOST:-nixos-laptop}"
TARGET="/var/lib/hermes/secrets.env"
GUEST_BIN="/run/current-system/sw/bin"

if [ -z "${BW_SESSION:-}" ]; then
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
fi

bw sync >/dev/null
env="$(bw get notes "$ITEM")"

if [ -z "$env" ]; then
  echo "Bitwarden item \"$ITEM\" needs the Hermes KEY=value lines in its notes" >&2
  exit 1
fi

key="$(ssh "$HOST" cliproxy-key)"

if [ -z "$key" ] || [ "$key" = "null" ]; then
  echo "Could not read the CLIProxyAPI key on $HOST" >&2
  exit 1
fi

printf '%s\nCLIPROXY_API_KEY=%s\n' "$env" "$key" |
  ssh "$HOST" "incus file push - hermes$TARGET --mode 0600 --uid 0 --gid 0 &&
    incus exec hermes -- /run/current-system/activate >/dev/null &&
    incus exec hermes -- $GUEST_BIN/systemctl restart hermes-agent hermes-backend"

echo "==> Wrote hermes:$TARGET on $HOST and restarted Hermes"
exit 0
