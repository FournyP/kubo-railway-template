# IPFS Kubo Railway Template

Deploys [Kubo](https://github.com/ipfs/kubo) — the reference IPFS node — on Railway with a persistent volume for the repo, an authenticated RPC API and a swarm port reachable through a TCP proxy.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/kubo?referralCode=C3Uv6n&utm_medium=integration&utm_source=template&utm_campaign=generic)

## 🏗️ Architecture

```
client ──Authorization: Bearer <secret>──► kubo :5001 (RPC API, public domain)
peers  ──libp2p──────────────────────────► kubo :4001 (swarm, TCP proxy)
                                              │
                                              ▼
                                        kubo-data volume (/data/ipfs)
```

One Railway service, `kubo`, built from the official `ipfs/kubo` image at a pinned tag (see `Dockerfile`). Listen addresses, the announce address and API authorization are applied through Kubo's `/container-init.d` hooks on every start, so the official entrypoint and CMD are untouched. The repo lives on a Railway volume, so blocks, pins and the peer identity survive redeploys.

## ✨ Features

- Official Kubo image at a pinned tag
- Repo on a persistent volume, ownership fixed on first boot
- RPC API behind Kubo's own `API.Authorizations`: a single bearer token, or a full per-user rule set
- Dual-stack listen addresses, matching Railway's IPv4 proxy and IPv6 private network
- Pin migration script for moving to a new node

## 💁‍♀️ How to use

1. Click the Railway button 👆
2. Fill in the variables (see below)
3. Deploy! 🚄
4. Add a TCP proxy on port `4001` in the dashboard and put the address it gives you in `KUBO_ANNOUNCE`, so other peers can reach the node. Then:
   ```bash
   curl -X POST -H "Authorization: Bearer <secret>" https://<kubo-domain>/api/v0/id
   ```

## 🧱 Infrastructure as Code

`.railway/railway.ts` defines the whole project — the node, its volume and every variable.

```bash
railway link
npm install

# First apply only; later runs omit this and preserve() keeps the value.
export KUBO_API_AUTH_SECRET=$(openssl rand -hex 32)

npm run plan     # read the diff before applying
npm run apply
railway domain --service kubo
```

The swarm port (`4001`) needs a TCP proxy, which IaC does not cover. Add one in the
dashboard and set `KUBO_ANNOUNCE` to the address it gives you; the default is only
reachable inside Railway.

Needs the Railway CLI 5.42.1 or newer: the IaC engine ships in the CLI, not in the npm
package. If you forked this repo, change `REPO` in `railway.ts` to your own before applying.

Link it to a project dedicated to this template. An apply deletes every resource **and
every variable** the file does not declare, so from then on variables live in `railway.ts`,
not the dashboard. Do not point it at a project created from the deploy button — the
service names differ, and a mismatch is a delete and recreate, not a rename.

## ⬆️ Upgrading

Railway template updates are opt-in — an existing deployment keeps running until you apply the update. See the [changelog](CHANGELOG.md) for what each update contains.

## 🔧 Variables

| Variable                      | Required | Description                                                                                                                      |
| ----------------------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `KUBO_API_AUTH_SECRET`        | one of   | Single bearer token for the RPC API (mode A). Generate with `openssl rand -hex 32`.                                              |
| `KUBO_API_AUTHORIZATIONS`     | one of   | Full `API.Authorizations` JSON object (mode B). Wins over mode A when set.                                                       |
| `KUBO_API_ALLOWED_PATHS`      | no       | JSON array of paths the mode A token may call, default `["/api/v0"]`.                                                            |
| `KUBO_ANNOUNCE`               | no       | Multiaddr announced to peers, e.g. `/dns/<tcp-proxy-domain>/tcp/<tcp-proxy-port>`. The default is only reachable inside Railway. |
| `KUBO_API_ADDRESSES`          | no       | JSON array of RPC API listen addresses, default `["/ip4/0.0.0.0/tcp/5001", "/ip6/::/tcp/5001"]`.                                 |
| `KUBO_SWARM_TCP_ADDRESS_IPV4` | no       | Default `/ip4/0.0.0.0/tcp/4001`.                                                                                                 |
| `KUBO_SWARM_TCP_ADDRESS_IPV6` | no       | Default `/ip6/::/tcp/4001`.                                                                                                      |
| `KUBO_SWARM_UDP_ADDRESS_IPV4` | no       | Default `/ip4/0.0.0.0/udp/4001/quic`.                                                                                            |
| `KUBO_SWARM_UDP_ADDRESS_IPV6` | no       | Default `/ip6/::/udp/4001/quic`.                                                                                                 |
| `IPFS_PATH`                   | no       | Kubo's repo directory, default `/data/ipfs`. Must be the volume's mount path.                                                    |

Leave the API unauthenticated and anyone who finds the domain owns the node. Set one of the two auth modes before giving the service a public domain.

## 🔐 Authentication

The RPC API (port `5001`) is admin-level — protect it before exposing it.
Pick **one** of two mutually exclusive modes:

**Mode A — single bearer token (simple).** Set `KUBO_API_AUTH_SECRET`, and
optionally `KUBO_API_ALLOWED_PATHS` (default `["/api/v0"]`) to narrow what the
token can call. Callers send an `Authorization: Bearer <secret>` header:

```bash
curl -X POST -H "Authorization: Bearer $KUBO_API_AUTH_SECRET" \
  https://<your-domain>/api/v0/id
```

**Mode B — full rules (advanced).** Set `KUBO_API_AUTHORIZATIONS` to the entire
[`API.Authorizations`](https://github.com/ipfs/kubo/blob/master/docs/config.md#apiauthorizations)
JSON object for multiple users, per-user `AllowedPaths`, and `basic:`/`bearer:`
secrets.

> If `KUBO_API_AUTHORIZATIONS` is set it **wins** and `KUBO_API_AUTH_SECRET` /
> `KUBO_API_ALLOWED_PATHS` are ignored — set one mode or the other, not both.

Note: tokens are trusted — anyone holding one shares the same node, and IPFS has
no read privacy, so encrypt sensitive data before adding.

## 🌐 API listen addresses

`KUBO_API_ADDRESSES` (JSON array) defaults to
`["/ip4/0.0.0.0/tcp/5001", "/ip6/::/tcp/5001"]` — keep both on Railway (the
public proxy is IPv4, the private network IPv6).

## 🔁 Pin migration

`scripts/migrate-pins.sh` copies all recursive pins from one node to another
(`dag export`/`dag import`). Data transfer only — both nodes must already be
configured and reachable:

```bash
SRC_TOKEN=... DST_TOKEN=... ./scripts/migrate-pins.sh https://old-node https://new-node [--list]
```

## 📝 Notes

- This template uses Kubo's `/container-init.d` hooks and keeps the official entrypoint/CMD.
- Source repo: https://github.com/FournyP/kubo-railway-template
- Docs: https://docs.ipfs.tech/how-to

## ⚖️ License

[MIT](LICENSE)
