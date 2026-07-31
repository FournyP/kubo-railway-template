#!/bin/sh

set -e

echo "KUBO_SWARM_TCP_ADDRESS_IPV4: $KUBO_SWARM_TCP_ADDRESS_IPV4"
echo "KUBO_SWARM_TCP_ADDRESS_IPV6: $KUBO_SWARM_TCP_ADDRESS_IPV6"
echo "KUBO_SWARM_UDP_ADDRESS_IPV4: $KUBO_SWARM_UDP_ADDRESS_IPV4"
echo "KUBO_SWARM_UDP_ADDRESS_IPV6: $KUBO_SWARM_UDP_ADDRESS_IPV6"
echo "KUBO_ANNOUNCE: $KUBO_ANNOUNCE"
echo "KUBO_API_ADDRESSES: $KUBO_API_ADDRESSES"
echo "IPFS_PATH: $IPFS_PATH"

ipfs --repo-dir="$IPFS_PATH" config Addresses.Swarm "[\"${KUBO_SWARM_TCP_ADDRESS_IPV4}\", \"${KUBO_SWARM_TCP_ADDRESS_IPV6}\", \"${KUBO_SWARM_UDP_ADDRESS_IPV4}\", \"${KUBO_SWARM_UDP_ADDRESS_IPV6}\"]" --json
ipfs --repo-dir="$IPFS_PATH" config Addresses.Announce "[\"${KUBO_ANNOUNCE}\"]" --json
ipfs --repo-dir="$IPFS_PATH" config Addresses.API "$KUBO_API_ADDRESSES" --json
ipfs --repo-dir="$IPFS_PATH" config Routing.Type "dht"
ipfs --repo-dir="$IPFS_PATH" config Provide.DHT.Interval "30m"
ipfs --repo-dir="$IPFS_PATH" config Provide.Strategy "all"

if [ -n "$KUBO_API_AUTHORIZATIONS" ]; then
  ipfs --repo-dir="$IPFS_PATH" config --json API.Authorizations "$KUBO_API_AUTHORIZATIONS"
  echo "API.Authorizations: configured from KUBO_API_AUTHORIZATIONS"
elif [ -n "$KUBO_API_AUTH_SECRET" ]; then
  allowed_paths="$KUBO_API_ALLOWED_PATHS"
  if [ -z "$allowed_paths" ]; then
    allowed_paths='["/api/v0"]'
  fi
  ipfs --repo-dir="$IPFS_PATH" config --json API.Authorizations \
    "{\"railway\":{\"AuthSecret\":\"bearer:${KUBO_API_AUTH_SECRET}\",\"AllowedPaths\":${allowed_paths}}}"
  echo "API.Authorizations: bearer auth ENABLED (AllowedPaths=${allowed_paths})"
else
  echo "WARNING: no API auth configured — RPC API (:5001) is UNAUTHENTICATED. Do not expose publicly."
fi