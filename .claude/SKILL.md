---
name: zimaos-app-creator
description: Use when adding a new app or updating an existing app in Hira's Zima OS App Store (the HSinghHira/ZimaAppStore GitHub repo) — producing a compliant docker-compose.yml with x-casaos metadata, claiming a port, handling secrets/env vars, writing the README.md table row, and running the pre-push checklist. Trigger on requests like "add an app to the Zima app store", "publish an app to ZimaAppStore", "write a docker-compose.yml for the app store", or "update a ZimaAppStore manifest".
---

# Adding/updating an app in Hira's Zima OS App Store

This store is a curated collection of `docker-compose.yml` manifests, built
with `IceWhaleTech/build-appstore-action`, that let Zima OS users install
self-hosted apps with one click. This skill turns an upstream app's
name/image/ports/env vars into a compliant manifest and a matching
README row.

## Step 0 — get the current port ledger (do this first, every time)

The port ledger changes constantly, so it is **not** bundled in this
skill. Before doing anything else, fetch the live version from GitHub:

```
https://raw.githubusercontent.com/HSinghHira/ZimaAppStore/main/docs/adding-apps/PORT_LEDGER.md
```

Use this fetched table as the source of truth for the next unused port —
ignore any port numbers you might recall from a previous conversation,
they may be stale. If the fetch fails (no network access, repo path
changed, etc.), stop and ask the user to paste the current ledger instead
of guessing a port number.

## Order of operations

1. **Claim a port** from the fetched ledger (see Step 0). Note the
   number(s) you're using and tell the user to add the row to
   `PORT_LEDGER.md` in the repo before merging — this skill can't write
   back to GitHub itself.
2. **Write `docker-compose.yml`** following `references/ARCHITECTURE.md`
   exactly — required top-level keys, per-service keys, the `x-casaos`
   block. For `PUID`/`PGID`/`TZ` and other variables, see
   `references/VARIABLES.md`.
3. **Follow `references/SECRETS.md`** for every `environment:` entry —
   placeholders and generated secrets are not interchangeable.
4. **Add icon/thumbnail** per `references/ARCHITECTURE.md` §5
   (self-hosted via jsdelivr, never upstream's own CDN).
5. **Add a README row** per `references/PUBLISHING_README.md`, in the
   same position as the app's row in the port ledger.
6. **Run `references/PRE_PUSH_CHECKLIST.md`** top to bottom before
   presenting the result as done.

Read `references/EXAMPLE.md` once if this is your first time through —
it shows all of the above applied to one real, fictional app.

## Non-negotiable behavior rules

- **Never put explanatory `#` comments in `docker-compose.yml`.** If
  something needs explaining, it goes in a real `x-casaos` field the
  store UI shows (see `references/ARCHITECTURE.md` §8 for exactly which
  field). The only exception is commenting out `thumbnail`/
  `screenshot_link` as a placeholder toggle.
- **Write `tips.before_install` like you're explaining it to a 4th
  grader.** Short sentences, everyday words, one instruction per numbered
  step. No restating why a design decision was made, no hedging, no
  digressions into how something works internally.
- **Validate YAML** before treating any manifest as done — a syntax error
  won't always fail loudly in the build action.
- **Never leave `<your-username>/<your-repo-name>`-style placeholders**
  in anything meant to be committed.
- **Category must come from the fixed list** in
  `references/ARCHITECTURE.md` §3 — don't invent a new one.

## When you're unsure

If upstream's install docs conflict with a rule here (e.g. they recommend
a config-file mount but `references/ARCHITECTURE.md` §4 prefers env
vars), follow this skill — it reflects real failures already hit in this
store, not theoretical concerns.
