#!/usr/bin/env bash
set -e

SRC="${MUSIC_SRC:-$HOME/Music}"
HOST="${MUSIC_HOST:-nixos-laptop}"
DEST="${MUSIC_DEST:-/srv/music}"
RETRIES="${MUSIC_RETRIES:-5}"

usage() {
  echo "Usage: $(basename "$0") [--dry-run] [--delete]"
  echo "Copy $SRC to $HOST:$DEST for Navidrome."
  echo "  --dry-run  show what would change"
  echo "  --delete   remove files on $HOST that are not in $SRC"
}

args=(-a -P -h -v --inplace --stats --chmod=u=rwX,go=rX)
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) args+=(--dry-run) ;;
    --delete) args+=(--delete) ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done

if [ ! -d "$SRC" ]; then
  echo "Source folder $SRC does not exist" >&2
  exit 1
fi

if ! ssh "$HOST" "mountpoint -q '$DEST'"; then
  echo "$HOST:$DEST is not a mounted volume" >&2
  exit 1
fi

attempt=1
while true; do
  status=0
  rsync "${args[@]}" \
    -e "ssh -o ControlMaster=no -o ControlPath=none" \
    --exclude='.DS_Store' \
    --exclude='._*' \
    --exclude='.localized' \
    --exclude='.library.db*' \
    --exclude='.thumbnails' \
    "$SRC/" "$HOST:$DEST/" || status=$?
  if [ "$status" -ne 255 ] || [ "$attempt" -ge "$RETRIES" ]; then
    ssh "$HOST" "chmod 755 '$DEST'"
    exit "$status"
  fi
  attempt=$((attempt + 1))
  echo "==> Connection lost, retry $attempt of $RETRIES in 10s" >&2
  sleep 10
done
