# PRE_PUSH_CHECKLIST.md — final gate before opening a PR

Run through all of these before pushing. Each item points to the doc with
the full rule if you need to double-check something.

1. **Validate YAML** for every changed/new `docker-compose.yml`.
2. **Confirm the port ledger in the repo (`docs/adding-apps/PORT_LEDGER.md`)
   is updated and non-colliding** — no port above 65535, no 5-digit
   `840xx`-style typo. (This skill fetches the ledger live from GitHub at
   the start of a session — see `SKILL.md` Step 0 — so re-check it wasn't
   claimed by someone else in the meantime.)
3. **Confirm no personal secrets anywhere in the diff.** Every
   cryptographic-secret var uses a freshly generated random value, not a
   `CHANGEME_*` placeholder, and has a description pointing the installer
   to randomkeygen.com / bcrypt-generator.com (see `SECRETS.md`).
4. **Confirm `category:`** is one of the fixed values in
   `ARCHITECTURE.md` §3.
5. **Confirm icon/thumbnail/screenshot URLs** point at this repo's
   jsdelivr mirror, not upstream (see `ARCHITECTURE.md` §5).
6. **Confirm `x-casaos.id` is present** at the top level and mirrored
   into each service's `x-casaos:` block, and isn't already used by
   another app.
7. **If `version`/`update_at`/`release_notes` are present**, confirm
   `version` matches the actually-pinned image tag and `release_notes`
   reflects *this* change — not copy-pasted from the last app.
8. **Confirm `README.md` has a matching row** (icon, tags, port badge(s),
   description, thumbnail) for every app added or changed — see
   `PUBLISHING_README.md`.
9. **Confirm `docker-compose.yml` has no explanatory `#` comments**
   anywhere — only the allowed commented-out placeholder fields
   (`thumbnail`/`screenshot_link`) may remain.
10. **Read `tips.before_install` back and confirm it's written in
    simple, 4th-grade-level language** — short sentences, no
    over-explaining.
11. **If `PUID`/`PGID`/`TZ` are set**, confirm they are plain values (not
    `CHANGEME_*`, not generated), have an `x-casaos.envs[].description`,
    and that no shell-only variable (`$HOME`, `$USER`, etc.) is used as an
    install-time value — see `VARIABLES.md`.
