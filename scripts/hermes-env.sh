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
    incus exec hermes -- /run/current-system/activate >/dev/null"

ssh "$HOST" "incus exec hermes -- $GUEST_BIN/sh -s" <<EOF
set -e
export PATH=$GUEST_BIN
line=\$(grep '^CLIPROXY_API_KEY=' $TARGET)
for env in /var/lib/hermes/.hermes/profiles/*/.env; do
  [ -e "\$env" ] || continue
  sed -i '/^CLIPROXY_API_KEY=/d' "\$env"
  printf '%s\n' "\$line" >> "\$env"
  chown hermes:hermes "\$env"
  chmod 600 "\$env"
done
systemctl restart hermes-agent hermes-backend
EOF

echo "==> Wrote hermes:$TARGET on $HOST and restarted Hermes"
exit 0
