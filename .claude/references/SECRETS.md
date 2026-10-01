# SECRETS.md — env vars, secrets, and placeholders

**Nothing personal (real email, real API keys, real passwords) goes in
the repo — ever.** This store is public.

## Two kinds of env var

**Identifying credentials** (SMTP login/username, an account email, an
API *username* — things that just identify something, not cryptographic
secrets) ship as a `CHANGEME_*` placeholder in `environment:`, with a
matching `x-casaos.envs[].description` explaining what to put there and
why.

**Cryptographic secrets** (`SECRET_KEY`, `JWT_SECRET`, session/cookie
signing keys, encryption keys, bcrypt/argon2 password hashes, API *keys*
— not usernames) must **not** ship as `CHANGEME_*`. Generate a real random
value instead (`openssl rand -hex 32`, or a UUID/base64 token of the
length upstream expects) and put that generated value directly in
`environment:`. A `CHANGEME_*` placeholder is a worse default here: most
apps will boot and run fine with the literal placeholder still in place,
which quietly ships every install with the same guessable key — an app
that fails to start until you set a real secret is safer than that.

Every generated-secret var still needs an `x-casaos.envs[].description`
telling the installer it's pre-filled with a random value **and** that
they should replace it with their own before relying on the app for
anything sensitive. Point them at a generator matching the value's
format:

- General random strings/tokens (`SECRET_KEY`, session keys, API keys):
  [randomkeygen.com](https://randomkeygen.com/)
- bcrypt password hashes specifically:
  [bcrypt-generator.com](https://bcrypt-generator.com/)

Example description: `"Pre-filled with a random value. Replace it with
your own — generate one at [randomkeygen.com](https://randomkeygen.com/) —
before going live."`

## What is not a placeholder

Time zones, user/group IDs, ports, and the app's own URL are not
placeholders and not secrets. They use dynamic variables
(`TZ=$TZ`, `PUID=$PUID`, `PGID=$PGID`, `APP_URL=http://localhost:$PORT`).
See `VARIABLES.md`. Never write `CHANGEME_ZIMAOS_IP` or a hardcoded time
zone.

## Cross-service dependencies

Passwords that must match across two services (e.g. a DB password shared
between an app and its Postgres container) get that noted in **both**
vars' `x-casaos.envs[].description` — e.g. "must match `POSTGRES_PASSWORD`
in the `db` service" — not a comment in the file.

## External services

If the app needs an external service to function fully (e.g. real email
sending), prefer bundling a **generic, self-contained relay/service**
(see Ente's `postfix` service) over hardcoding one provider's config.
Installers bring their own credentials at install time; the repo stays
provider-agnostic.

## What `tips.before_install` must cover

`tips.before_install` is a single numbered list covering the full
install-to-first-use sequence, not just pre-install prep:

1. Placeholder values to replace — name the exact `CHANGEME_*` vars and
   which services they're in.
2. Pre-filled random secret values to swap for the installer's own — name
   the exact vars (e.g. `SECRET_KEY`) and link to
   [randomkeygen.com](https://randomkeygen.com/) or
   [bcrypt-generator.com](https://bcrypt-generator.com/) as above.
3. Any password/value that must match across services.
4. When to wait for a migration job before first use.
5. First-run account setup.
6. Where post-install config lives.
7. Any one-way gotchas — e.g. env vars that only apply at DB init time and
   can't be changed later by editing the compose file.
8. If an app URL env var starts as `localhost` and the app builds links
   other devices open, one step telling the user to change `localhost` to
   their ZimaOS IP (see `VARIABLES.md`).

Don't add a step for `TZ=$TZ`. It fills in on its own. Add one for `TZ`
only if the user would have a real reason to change it.

**Write it like you're explaining it to a 4th grader** — short sentences,
everyday words, one instruction per numbered step. Don't over-explain: no
restating why a design decision was made, no digressions into how
something works internally, no hedging piled onto a single step. Say "Set
`DB_PASSWORD` to a password you make up," not "Set `DB_PASSWORD` to a
strong, unique password of your choosing, which will be used to
authenticate the application's connection to the underlying database." If
a step needs a "why," give it in five words or fewer.

Leave a blank line between numbered items — YAML block scalars fold
single newlines into spaces, so without blank lines the steps run
together into one line.