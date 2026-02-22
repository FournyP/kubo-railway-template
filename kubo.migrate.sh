#!/bin/sh

set -e

echo "Running ipfs repo migrate"
ipfs repo migrate --repo-dir="$IPFS_PATH" --to=18
