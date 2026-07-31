# IPFS Kubo Railway Template

This example deploys a server of [Kubo](https://github.com/ipfs/kubo).

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/pUNeRR?referralCode=C3Uv6n&utm_medium=integration&utm_source=template&utm_campaign=generic)

## ✨ Features

- Kubo

## 💁‍♀️ How to use

- Click the Railway button 👆
- Fill in the variables
- Deploy! 🚄

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

## 📝 Notes

- This template uses Kubo's `/container-init.d` hooks and keeps the official entrypoint/CMD.
- Source repo: https://github.com/FournyP/kubo-railway-template
- Docs: https://docs.ipfs.tech/how-to
