# AGENTS.md — Working on Hira's Zima OS App Store

You are adding or updating an app in this store. Follow this order — each
step depends on the one before it.

## Order of operations

1. **Read `PORT_LEDGER.md` first.** Claim the next unused port(s) and add
   your app to the table *before* writing the manifest — this avoids two
   apps in progress at once colliding.
2. **Write `docker-compose.yml`** following `ARCHITECTURE.md` exactly —
   required top-level keys, per-service keys, the `x-casaos` block.
3. **Follow `SECRETS.md`** for every `environment:` entry — placeholders
   and generated secrets are not interchangeable.
4. **Add icon/thumbnail** per `ARCHITECTURE.md` §5 (self-hosted via
   jsdelivr, never upstream's own CDN).
5. **Add a README row** per `PUBLISHING_README.md`, in the same position
   as your app's row in the port ledger.
6. **Run `PRE_PUSH_CHECKLIST.md`** top to bottom before considering the
   work done.

Read `EXAMPLE.md` once before starting — it shows all of the above applied
to one real app, start to finish.

## Non-negotiable behavior rules

- **Never put explanatory `#` comments in `docker-compose.yml`.** If
  something needs explaining, it goes in a real `x-casaos` field the store
  UI shows (see `ARCHITECTURE.md` §8 for exactly which field). The only
  exception is commenting out `thumbnail`/`screenshot_link` as a
  placeholder toggle.
- **Write `tips.before_install` like you're explaining it to a 4th
  grader.** Short sentences, everyday words, one instruction per numbered
  step. No restating why a design decision was made, no hedging, no
  digressions into how something works internally. "Set `DB_PASSWORD` to
  a password you make up," not a clause about strong unique passwords
  authenticating database connections.
- **Validate YAML** before treating any manifest as done — a syntax error
  won't always fail loudly in the build action.
- **Never leave `<your-username>/<your-repo-name>`-style placeholders** in
  anything meant to be committed.
- **Category must come from the fixed list** in `ARCHITECTURE.md` §3 —
  don't invent a new one.

## When you're unsure

If upstream's install docs conflict with a rule here (e.g. they recommend
a config-file mount but `ARCHITECTURE.md` §4 prefers env vars), follow
this doc set — it reflects real failures already hit in this store, not
theoretical concerns.
