#!/bin/sh

set -e

# Debugging: Print environment variables used in the script
echo "KUBO_SWARM_TCP_ADDRESS_IPV4: $KUBO_SWARM_TCP_ADDRESS_IPV4"
echo "KUBO_SWARM_TCP_ADDRESS_IPV6: $KUBO_SWARM_TCP_ADDRESS_IPV6"
echo "KUBO_SWARM_UDP_ADDRESS_IPV4: $KUBO_SWARM_UDP_ADDRESS_IPV4"
echo "KUBO_SWARM_UDP_ADDRESS_IPV6: $KUBO_SWARM_UDP_ADDRESS_IPV6"
echo "KUBO_ANNOUNCE: $KUBO_ANNOUNCE"
echo "KUBO_API_ADDRESS: $KUBO_API_ADDRESS"
echo "IPFS_PATH: $IPFS_PATH"

echo "Kubo binary version: $(ipfs version)"
if [ -f "$IPFS_PATH/version" ]; then
  echo "Repo format version: $(cat "$IPFS_PATH/version")"
else
  echo "Repo format version: (missing)"
fi

# Initialize IPFS if not already initialized
if [ ! -f "$IPFS_PATH/config" ]; then
  echo "Initializing IPFS..."
  ipfs init --repo-dir="$IPFS_PATH"
else
  echo "IPFS already initialized."
fi

# Merge or update the config.json file
ipfs --repo-dir="$IPFS_PATH" config Addresses.Swarm "[\"${KUBO_SWARM_TCP_ADDRESS_IPV4}\", \"${KUBO_SWARM_TCP_ADDRESS_IPV6}\", \"${KUBO_SWARM_UDP_ADDRESS_IPV4}\", \"${KUBO_SWARM_UDP_ADDRESS_IPV6}\"]" --json
ipfs --repo-dir="$IPFS_PATH" config Addresses.Announce "[\"${KUBO_ANNOUNCE}\"]" --json
ipfs --repo-dir="$IPFS_PATH" config Addresses.API "[\"${KUBO_API_ADDRESS}\"]" --json
ipfs --repo-dir="$IPFS_PATH" config Routing.Type "dht"
ipfs --repo-dir="$IPFS_PATH" config Provide.DHT.Interval "30m"
ipfs --repo-dir="$IPFS_PATH" config Provide.Strategy "all"