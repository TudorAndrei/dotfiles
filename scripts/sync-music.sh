#!/usr/bin/env bash
set -e

SRC="${MUSIC_SRC:-$HOME/Music}"
HOST="${MUSIC_HOST:-nixos-laptop}"
DEST="${MUSIC_DEST:-/srv/music}"

usage() {
  echo "Usage: $(basename "$0") [--dry-run] [--delete]"
  echo "Copy $SRC to $HOST:$DEST for Navidrome."
  echo "  --dry-run  show what would change"
  echo "  --delete   remove files on $HOST that are not in $SRC"
}

args=(-a --partial --progress --stats --chmod=u=rwX,go=rX)
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

rsync "${args[@]}" \
  --exclude='.DS_Store' \
  --exclude='._*' \
  --exclude='.localized' \
  --exclude='.library.db*' \
  --exclude='.thumbnails' \
  "$SRC/" "$HOST:$DEST/"

exit 0
