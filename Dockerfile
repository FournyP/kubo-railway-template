FROM ipfs/kubo:v0.39.0

ENV IPFS_PATH=/data/ipfs
ENV KUBO_SWARM_TCP_ADDRESS_IPV4=/ip4/0.0.0.0/tcp/4001
ENV KUBO_SWARM_TCP_ADDRESS_IPV6=/ip6/::/tcp/4001
ENV KUBO_SWARM_UDP_ADDRESS_IPV4=/ip4/0.0.0.0/udp/4001/quic
ENV KUBO_SWARM_UDP_ADDRESS_IPV6=/ip6/::/udp/4001/quic
ENV KUBO_ANNOUNCE=/ip4/0.0.0.0/tcp/4001
ENV KUBO_API_ADDRESS=/ip6/::/tcp/5001

# Use container-init.d hook to configure IPFS before daemon start
COPY --chmod=755 kubo.config.sh /container-init.d/10-kubo-config.sh

# Expose ports for Kubo
EXPOSE 4001 5001