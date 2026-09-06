# IPFS Kubo Railway Template

This example deploys a server of [Kubo](https://github.com/ipfs/kubo).

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/kubo?referralCode=C3Uv6n&utm_medium=integration&utm_source=template&utm_campaign=generic)

## ✨ Features

- Kubo

## 💁‍♀️ How to use

- Click the Railway button 👆
- Fill in the variables
- Deploy! 🚄

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
