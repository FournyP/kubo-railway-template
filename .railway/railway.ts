// Railway Infrastructure as Code: railway config plan | apply
//
// An apply deletes every resource this file does not declare, so link it to a
// project dedicated to this template.
//
// The RPC API is admin-level. Pick one auth mode and export its secret for the
// first apply; later runs omit it and preserve() keeps Railway's.
//
//   export KUBO_API_AUTH_SECRET=$(openssl rand -hex 32)
//
// or, for multiple users and per-user path scopes:
//
//   export KUBO_API_AUTHORIZATIONS='{"alice":{"AuthSecret":"bearer:...","AllowedPaths":["/api/v0/add"]}}'

import { defineRailway, github, preserve, project, service, volume } from "railway/iac";

const REPO = "FournyP/kubo-railway-template";

// Matched by name, so keep these identical to Railway: a mismatch is a
// delete and recreate, not a rename.
const KUBO_SERVICE = "kubo";
const DATA_VOLUME = "kubo-data";

// Kubo's repo directory, read as IPFS_PATH by the image and its init hooks.
// Detaching this volume loses the node's identity along with its blocks.
const IPFS_PATH = "/data/ipfs";

/** Push the value from the local environment if present, else keep Railway's. */
const fromEnvOrPreserve = (name: string) => process.env[name] ?? preserve();

export default defineRailway(() => {
  const data = volume(DATA_VOLUME, { sizeMB: 5120 });

  const kubo = service(KUBO_SERVICE, {
    source: github(REPO, { branch: "main" }),
    build: { builder: "DOCKERFILE", dockerfilePath: "Dockerfile" },
    volumeMounts: {
      [IPFS_PATH]: data,
    },
    deploy: {
      // A second replica gets no volume and a second peer identity.
      numReplicas: 1,
    },
    env: {
      // Same value as the Dockerfile's ENV, declared so the mount path and the
      // repo directory cannot drift apart.
      IPFS_PATH,

      // Railway's private network is IPv6, its public proxy IPv4. Answer on both.
      KUBO_API_ADDRESSES: '["/ip4/0.0.0.0/tcp/5001", "/ip6/::/tcp/5001"]',
      KUBO_SWARM_TCP_ADDRESS_IPV4: "/ip4/0.0.0.0/tcp/4001",
      KUBO_SWARM_TCP_ADDRESS_IPV6: "/ip6/::/tcp/4001",
      KUBO_SWARM_UDP_ADDRESS_IPV4: "/ip4/0.0.0.0/udp/4001/quic",
      KUBO_SWARM_UDP_ADDRESS_IPV6: "/ip6/::/udp/4001/quic",

      // What peers are told to dial. Set this to the TCP proxy's address once
      // you add one; preserved so an apply does not revert it to the default,
      // which is only reachable inside Railway.
      KUBO_ANNOUNCE: process.env.KUBO_ANNOUNCE ?? preserve(),

      // Mode A is a single bare token; kubo.config.sh adds the "bearer:" prefix.
      // Mode B takes a full API.Authorizations object and wins over Mode A.
      // Both are preserved: an apply that dropped them would bring the RPC API
      // back up unauthenticated.
      KUBO_API_AUTH_SECRET: fromEnvOrPreserve("KUBO_API_AUTH_SECRET"),
      KUBO_API_AUTHORIZATIONS: fromEnvOrPreserve("KUBO_API_AUTHORIZATIONS"),
      KUBO_API_ALLOWED_PATHS: process.env.KUBO_API_ALLOWED_PATHS ?? preserve(),
    },
  });

  return project("Kubo", { resources: [data, kubo] });
});
