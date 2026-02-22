FROM ipfs/kubo:v0.39.0

ENV IPFS_PATH=/data/ipfs
ENV KUBO_SWARM_TCP_ADDRESS_IPV4=/ip4/0.0.0.0/tcp/4001
ENV KUBO_SWARM_TCP_ADDRESS_IPV6=/ip6/::/tcp/4001
ENV KUBO_SWARM_UDP_ADDRESS_IPV4=/ip4/0.0.0.0/udp/4001/quic
ENV KUBO_SWARM_UDP_ADDRESS_IPV6=/ip6/::/udp/4001/quic
ENV KUBO_ANNOUNCE=/ip4/0.0.0.0/tcp/4001
ENV KUBO_API_ADDRESS=/ip6/::/tcp/5001

# Override the entrypoint to run our custom script before the original entrypoint
COPY --chmod=755 entrypoint.override.sh /entrypoint.override.sh

# Use container-init.d hooks to migrate and configure IPFS before daemon start
COPY --chmod=755 kubo.migrate.sh /container-init.d/00-kubo-migrate.sh
COPY --chmod=755 kubo.config.sh /container-init.d/10-kubo-config.sh

# Expose ports for Kubo
EXPOSE 4001 5001

ENTRYPOINT [ "/entrypoint.override.sh" ]
CMD ["daemon", "--agent-version-suffix=docker"]