# Changelog

Notable changes to this template. Entries are named after the Kubo version they ship, or
after the change itself when a release only touches this template. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before applying an update to a deployment that uses a volume, read [Upgrading](README.md#️-upgrading).

## Repo path variable — 2026-09-18

### Fixed

- `railway.ts` declared `DATA_PATH`, which nothing in the image reads. It now declares
  `IPFS_PATH`, the variable Kubo and the init hooks actually use, with the same value as the
  Dockerfile. An apply removes the dead variable.

## Infrastructure as Code — 2026-09-06

### Added

- `.railway/railway.ts`, an Infrastructure as Code definition of the project. See
  [Infrastructure as Code](README.md#-infrastructure-as-code).
- CI: `docker-build` builds the image, `iac-typecheck` typechecks `railway.ts`.
- The IPFS repo volume is declared with the service, so an apply cannot start a node on
  an empty repo and generate a second peer identity.

## Kubo v0.41.0 — 2026-07-31

### Added

- Native RPC API authentication. `KUBO_API_AUTH_SECRET` configures a single credential;
  `KUBO_API_AUTHORIZATIONS` takes a full `API.Authorizations` object for multiple users
  with per-user path scopes, and wins if both are set.
- A pin migration script under `scripts/` for moving pins between nodes with
  `dag export`/`dag import`.

### Changed

- Upgraded the base image to Kubo v0.41.0.
- **Breaking:** `KUBO_API_ADDRESS` is replaced by `KUBO_API_ADDRESSES`, which takes a JSON
  array. The API now listens dual-stack by default — Railway's private network is IPv6
  and its public proxy is IPv4, so a single-stack listener was reachable on only one.

### Upgrade notes

- **Back up the volume first.** Kubo migrates the on-disk repo format in place on the
  first boot after an upgrade, and there is no downgrade.
- Replace `KUBO_API_ADDRESS` with `KUBO_API_ADDRESSES`. A deployment that still sets only
  the old variable falls back to the built-in dual-stack default; the daemon starts, but
  your custom listen address is silently ignored.

## Volume permissions and repo migration — 2026-02-22

### Added

- `kubo.migrate.sh`, which runs the repo migration before the daemon starts, so a base
  image bump does not strand an older on-disk repo format.
- A custom entrypoint that fixes volume ownership before handing off to the official one.

### Changed

- Configuration moved into `/container-init.d`, so it runs against an initialised repo
  rather than racing `ipfs init`.
