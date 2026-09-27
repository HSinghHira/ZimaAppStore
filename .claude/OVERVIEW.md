# Hira's Zima OS App Store — Publishing Overview

This store is a curated collection of `docker-compose.yml` manifests, built
with `IceWhaleTech/build-appstore-action`, that let Zima OS users install
self-hosted apps with one click.

**What "publishing an app" means:** every new or changed app needs:

1. A compliant `docker-compose.yml` in `Apps/<AppName>/` — see `ARCHITECTURE.md`
2. Unique, non-colliding published ports — see `PORT_LEDGER.md`
3. No real secrets in the repo, ever — see `SECRETS.md`
4. A self-hosted icon/thumbnail — see `ARCHITECTURE.md` §5
5. A matching row in the root `README.md` — see `PUBLISHING_README.md`
6. A clean pass through `PRE_PUSH_CHECKLIST.md` before opening a PR

**How to use these docs with an AI:** give it this file plus `AGENTS.md`,
then let it pull in the other files as it needs them — the port ledger
when claiming a port, `SECRETS.md` when writing `environment:`, and so on.
See `AGENTS.md` for the exact order of operations.

## Files in this set

| File | What it's for |
|---|---|
| `AGENTS.md` | How an AI agent should work through a submission, step by step |
| `ARCHITECTURE.md` | Required `docker-compose.yml` / `x-casaos` structure |
| `PORT_LEDGER.md` | The live port assignment table — update this every time |
| `SECRETS.md` | Rules for env vars, secrets, and placeholders |
| `PUBLISHING_README.md` | Format for the root `README.md` app table row |
| `PRE_PUSH_CHECKLIST.md` | Final gate before opening a PR |
| `EXAMPLE.md` | One fully worked example, start to finish |
