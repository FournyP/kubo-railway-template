#!/bin/sh

set -e

# Debugging: Print environment variables used in the script
echo "KUBO_SWARM_TCP_ADDRESS_IPV4: $KUBO_SWARM_TCP_ADDRESS_IPV4"
echo "KUBO_SWARM_TCP_ADDRESS_IPV6: $KUBO_SWARM_TCP_ADDRESS_IPV6"
echo "KUBO_SWARM_UDP_ADDRESS_IPV4: $KUBO_SWARM_UDP_ADDRESS_IPV4"
echo "KUBO_SWARM_UDP_ADDRESS_IPV6: $KUBO_SWARM_UDP_ADDRESS_IPV6"
echo "KUBO_ANNOUNCE: $KUBO_ANNOUNCE"
echo "KUBO_API_ADDRESS: $KUBO_API_ADDRESS"
echo "DATA_PATH: $DATA_PATH"

# Initialize IPFS if not already initialized
if [ ! -f "$DATA_PATH/config" ]; then
  echo "Initializing IPFS..."
  ipfs init
else
  echo "IPFS already initialized."
fi

# Merge or update the config.json file
ipfs config Addresses.Swarm "[\"${KUBO_SWARM_TCP_ADDRESS_IPV4}\", \"${KUBO_SWARM_TCP_ADDRESS_IPV6}\", \"${KUBO_SWARM_UDP_ADDRESS_IPV4}\", \"${KUBO_SWARM_UDP_ADDRESS_IPV6}\"]" --json
ipfs config Addresses.Announce "[\"${KUBO_ANNOUNCE}\"]" --json
ipfs config Addresses.API "[\"${KUBO_API_ADDRESS}\"]" --json
ipfs config Routing.Type "dht"
ipfs config Provide.DHT.Interval "30m"
ipfs config Provide.Strategy "all"