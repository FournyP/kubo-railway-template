#!/bin/sh
# Copy all recursive pins from one Kubo node to another via dag export/import.
# Usage: [SRC_TOKEN=...] [DST_TOKEN=...] ./migrate-pins.sh <src-api-url> <dst-api-url> [--list]

set -e

SRC="$1"
DST="$2"
MODE="$3"

if [ -z "$SRC" ] || { [ -z "$DST" ] && [ "$MODE" != "--list" ]; }; then
  echo "usage: [SRC_TOKEN=...] [DST_TOKEN=...] $0 <src-api-url> <dst-api-url> [--list]" >&2
  exit 1
fi

pins=$(curl -sf -X POST ${SRC_TOKEN:+-H} ${SRC_TOKEN:+"Authorization: Bearer $SRC_TOKEN"} \
  "$SRC/api/v0/pin/ls?type=recursive" | grep -oE '"[A-Za-z0-9]+":\{"Type"' | cut -d'"' -f2 || true)

if [ -z "$pins" ]; then
  echo "no recursive pins on $SRC"
  exit 0
fi

echo "$pins"
[ "$MODE" = "--list" ] && exit 0

failed=0
for cid in $pins; do
  if curl -sf -X POST ${SRC_TOKEN:+-H} ${SRC_TOKEN:+"Authorization: Bearer $SRC_TOKEN"} \
      "$SRC/api/v0/dag/export?arg=$cid" \
    | curl -sf -X POST ${DST_TOKEN:+-H} ${DST_TOKEN:+"Authorization: Bearer $DST_TOKEN"} \
      -F "file=@-" "$DST/api/v0/dag/import?pin-roots=true" >/dev/null; then
    echo "migrated: $cid"
  else
    echo "FAILED: $cid" >&2
    failed=1
  fi
done
exit $failed
