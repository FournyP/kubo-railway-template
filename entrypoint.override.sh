#!/bin/sh

set -e

# Fix permissions before dropping privileges.
if [ -d "$IPFS_PATH" ]; then
  chown -R ipfs:users "$IPFS_PATH"
  if [ -f "$IPFS_PATH/config" ]; then
    chmod 640 "$IPFS_PATH/config"
  fi
fi

exec "/sbin/tini" -- "/usr/local/bin/start_ipfs" "$@"