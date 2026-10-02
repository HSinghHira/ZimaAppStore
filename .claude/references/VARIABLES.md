# VARIABLES.md — dynamic variables in manifests

**Read this before writing `environment:`, `ports:`, `healthcheck:`, or
`tips.before_install`.** ZimaOS fills dynamic variables in at install
time, so a manifest that uses them adapts to each user's box. A manifest
that hardcodes the same value (a time zone, an IP) is wrong for most
users.

## Variable table

| Variable        | Meaning                          | Example                        |
| --------------- | -------------------------------- | ------------------------------ |
| `$PUID`         | User ID to run the container as  | `1000`                         |
| `$PGID`         | Group ID to run the container as | `1000`                         |
| `$TZ`           | Time zone                        | `Pacific/Auckland`             |
| `$DATA_DIR`     | ZimaOS data directory            | `/DATA`                        |
| `$APP_DATA_DIR` | App's persistent-data directory  | `/DATA/AppData/<app>`          |
| `$HOME`         | Home directory                   | `/root` or `/DATA/AppData/...` |
| `$USER`         | Current username                 | `root`                         |
| `$UID`          | User ID                          | `1000`                         |
| `$GID`          | Group ID                         | `1000`                         |
| `$HOSTNAME`     | Container/host hostname          | varies                         |
| `$PATH`         | Executable search path           | varies                         |
| `$PWD`          | Current working directory        | varies                         |
| `$LANG`         | Locale/language                  | `C.UTF-8`                      |
| `$TERM`         | Terminal type                    | `xterm`                        |
| `$PORT`         | Port number                      | `80`                           |

## Variables you use in this store

### `$TZ` — always, whenever the app takes a time zone

```yaml
- TZ=$TZ
```

Never hardcode `Pacific/Auckland` or `Etc/UTC`. Add an
`x-casaos.envs[].description` such as "Your time zone. It is filled in
from your ZimaOS time zone. Leave it unless you need another."

### `$PUID` / `$PGID` — only when upstream lists them

```yaml
- PUID=$PUID
- PGID=$PGID
```

Add them only if upstream's docs or compose list them (LinuxServer.io
images, for example). If upstream doesn't, leave them out. Each gets a
description: "The user ID the app runs as. Leave it unless you know you
need another."

### `$PORT` — the main service's port

`$PORT` equals the main service's `x-casaos.port_map`. Use it in:

- Any env var that tells the app its **own listen port** (`APP_PORT`,
  `PORT`, `LISTEN_PORT`, and the like).
- Any env var that holds the **app's own URL** (`APP_URL`, `BASE_URL`,
  `NEXTAUTH_URL`, and the like).
- The main service's **healthcheck**.

```yaml
environment:
  - APP_URL=http://localhost:$PORT
  - APP_PORT=$PORT
ports:
  - target: 36400
    published: "36400"
    protocol: tcp
healthcheck:
  test: ["CMD", "curl", "-f", "http://127.0.0.1:$PORT/up"]
```

Rules:

- **Listen port set by env var:** `target` equals `published`. The
  container listens on `$PORT`, so it must be mapped as that number. Set
  `x-casaos.ports[].container` to the same number.
- **Listen port fixed by upstream (no env var):** keep upstream's port as
  `target`. Don't use `$PORT` for it. Use `$PORT` only in the app-URL
  variable if the app needs one, and map `published` to the ledger port.
- **`published` is always the literal ledger number** in quotes. Don't
  write `$PORT` there.
- **Only the main service.** Other services' ports stay literal.
  Internal-only services (a database, a cache, a proxy) keep their own
  fixed ports.
- **Unverified assumption:** `$PORT` is treated as equal to `port_map`,
  but this hasn't been checked against ZimaOS's source. Tell the user to
  confirm on first install. Fallback: hardcode the ledger port in those
  env vars and the healthcheck.

### App URLs default to `localhost`

An env var that holds the app's own URL ships as:

```yaml
- APP_URL=http://localhost:$PORT
```

Official ZimaOS apps do this (Blinko ships
`NEXTAUTH_URL: http://localhost:1111` and works). Do **not** invent
`CHANGEME_ZIMAOS_IP`-style placeholders for it.

`localhost` only works on the box itself. If the app uses this URL to
build links that other devices open (playlists, EPG or share links,
webhooks, OAuth redirects, email links), then:

1. Put that limit in the var's `x-casaos.envs[].description`: "Starts as
   localhost, which only works on this device. For other devices, change
   `localhost` to your ZimaOS IP."
2. Add one short step to `tips.before_install`: "Find `APP_URL` in the
   `<service>` service. To use links on other devices, change `localhost`
   to your ZimaOS IP address."

If the app only uses the URL for its own web login, the description alone
is enough.

## Variables you do not use

- **Data path stays `/DATA/AppData/$AppID`.** Every manifest in this store
  uses it (see `ARCHITECTURE.md` §2 and §4). Don't swap it for
  `$APP_DATA_DIR` or `$DATA_DIR`.
- **`$DATA_DIR` and `$APP_DATA_DIR`:** not confirmed as install-time
  substitutions in this store. If you want one, tell the user first so
  they can check.
- **Shell-only variables** (`$HOME`, `$USER`, `$UID`, `$GID`,
  `$HOSTNAME`, `$PATH`, `$PWD`, `$LANG`, `$TERM`) describe the shell inside
  a running container. They are not filled in at install time. If an app
  needs one, set a literal value (for example `LANG=C.UTF-8`).

## Descriptions and comments

Every `TZ`, `PUID`, `PGID`, `PORT`-based, and URL env var gets an
`x-casaos.envs[].description`. No `#` comments in the file
(`ARCHITECTURE.md` §8). Keep `tips.before_install` to the 4th-grade rule
in `SECRETS.md`. If a user may need to change one of these, add one short
step that names the variable and the service.