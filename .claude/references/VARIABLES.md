# VARIABLES.md — environment & system variables

Reference for variables that show up in manifests, container shells, and
install-time docs on Zima OS. Use this when filling `environment:`,
`volumes:`, or `tips.before_install`.

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

## How to use them in this store

- **Data path stays `/DATA/AppData/$AppID`.** That is the path every
  manifest in this store uses (see `ARCHITECTURE.md` §2 and §4). Do not
  swap it for `$APP_DATA_DIR` or `$DATA_DIR` — follow the store
  convention so all apps look the same.
- **`PUID` / `PGID` / `TZ`** are the ones apps most often ask for
  (LinuxServer.io-style images, for example). Add them to `environment:`
  only when upstream's docs list them. They are not secrets, so they are
  never generated and never use `CHANGEME_*`.
- **Defaults:** `PUID=1000`, `PGID=1000`. Use `TZ=Pacific/Auckland`
  unless the user names a different time zone.
- **Explain in the UI, not in a comment.** Any `PUID`, `PGID`, or `TZ`
  entry gets an `x-casaos.envs[].description` (for example: "The user ID
  the app runs as. Leave as 1000 unless you know you need another.").
  No `#` comments in the file (`ARCHITECTURE.md` §8).
- **Shell-only variables** (`$HOME`, `$USER`, `$UID`, `$GID`, `$HOSTNAME`,
  `$PATH`, `$PWD`, `$LANG`, `$TERM`) describe the shell inside a running
  container. Do not put them in a manifest value expecting them to be
  filled in at install time. If an app needs one, set it as a literal
  value (for example `LANG=C.UTF-8`).
- **`$DATA_DIR` and `$APP_DATA_DIR`:** these are listed for reference
  and have not been confirmed as install-time substitutions in this
  store. If you want to use one in a manifest, tell the user so they can
  check it first. Otherwise use the literal `/DATA/...` path.

## In `tips.before_install`

If a user may need to change `PUID`, `PGID`, or `TZ`, add one short step
that names the variable and the service. Example: "Find `TZ` in the
`pixelnote` service. Set it to your time zone." Keep to the 4th-grade
rule in `SECRETS.md`.
