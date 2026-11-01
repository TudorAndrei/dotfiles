#!/usr/bin/env bash
set -e

SRC="${MUSIC_SRC:-$HOME/Music}"
HOST="${MUSIC_HOST:-nixos-laptop}"
DEST="${MUSIC_DEST:-/srv/music}"
JOBS="${MUSIC_JOBS:-4}"
BATCH="${MUSIC_BATCH:-25}"

usage() {
  echo "Usage: $(basename "$0") [--dry-run] [--delete] [--jobs N]"
  echo "Copy $SRC to $HOST:$DEST for Navidrome."
  echo "  --dry-run  show what would change"
  echo "  --delete   remove files on $HOST that are not in $SRC"
  echo "  --jobs N   number of parallel rsync processes (default $JOBS)"
}

args=(-a --partial --chmod=u=rwX,go=rX
  --exclude='.DS_Store'
  --exclude='._*'
  --exclude='.localized'
  --exclude='.library.db*'
  --exclude='.thumbnails')
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run) args+=(--dry-run) ;;
    --delete) args+=(--delete) ;;
    -j|--jobs) JOBS="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
  shift
done

if [ ! -d "$SRC" ]; then
  echo "Source folder $SRC does not exist" >&2
  exit 1
fi

if ! ssh "$HOST" "mountpoint -q '$DEST'"; then
  echo "$HOST:$DEST is not a mounted volume" >&2
  exit 1
fi

cd "$SRC"
dirs=()
for d in *; do
  [ -d "$d" ] && dirs+=("$d")
done

echo "==> Copying ${#dirs[@]} folders with $JOBS parallel jobs"
printf '%s\0' "${dirs[@]}" |
  xargs -0 -n "$BATCH" -P "$JOBS" bash -c 'dest=$1; shift; rsync "$@" "$dest"' _ "$HOST:$DEST/" "${args[@]}" -R

echo "==> Final pass"
rsync "${args[@]}" --stats ./ "$HOST:$DEST/"

exit 0
