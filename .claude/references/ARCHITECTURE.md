# ARCHITECTURE.md — docker-compose.yml & x-casaos structure

## 1. Required top-level keys

```yaml
name: <appname>          # REQUIRED — omitted once and the app didn't
                          # appear in the store with no error. lowercase,
                          # matches the app's folder name in Apps/.

services:
  <appname>:              # primary service; service key = app name
    ...

x-casaos:                 # REQUIRED top-level block, see §3
  id: com.hiraappstore.<appname>
  ...
```

Missing `name:` caused a real app (Ente) to silently not appear in the
store. Missing `x-casaos.id` hard-fails the build action
(`IceWhaleTech/build-appstore-action`) with
`ERROR App 'X' is missing required x-casaos.id`.

## 2. Required per-service keys

For every service (not just the "main" one):

```yaml
services:
  <servicename>:
    image: <org>/<repo>:<tag>   # avoid :latest if upstream publishes real
                                 # tags; if they only publish floating tags
                                 # (latest/main/next), say so in
                                 # x-casaos.release_notes instead — see §6
    container_name: <servicename>
    restart: unless-stopped
    stop_grace_period: 40s       # give apps time to shut down cleanly;
                                  # adjust up for DBs/anything with WAL
    network_mode: bridge         # unless the app needs to share a network
                                  # namespace with a sibling service
    environment:
      - TZ=$TZ                    # dynamic variables: see VARIABLES.md
      - APP_URL=http://localhost:$PORT   # only if the app has a URL var
      - APP_PORT=$PORT            # only if the listen port is env-set
      - SOME_VAR=CHANGEME        # see SECRETS.md — never real secrets
    ports:                       # omit entirely for internal-only services
      - target: <container-port>  # equals <host-port> if the listen port
                                   # is set by $PORT; else upstream's port
        published: "<host-port>"  # from PORT_LEDGER.md, 4-digit 84xx only
        protocol: tcp
    volumes:
      - type: bind
        source: /DATA/AppData/$AppID
        target: <container-data-path>
        bind:
          create_host_path: true
    healthcheck:                  # include when upstream defines one;
      test: ["CMD", "curl", "-f", "http://127.0.0.1:$PORT/<health-path>"]
      interval: 30s               # use $PORT on the main service only
      timeout: 10s
      retries: 5
      start_period: 60s
    deploy:
      resources:
        limits:
          cpus: "<n>"
          memory: <n>M
        reservations:
          cpus: "0.00"
          memory: <n>M
    labels:
      icon: <self-hosted icon URL — see §5>
    x-casaos:
      id: com.hiraappstore.<appname>   # mirror the top-level id here too
      envs:
        - container: SOME_VAR
          description:
            en_US: <what to put here and why>
      ports:
        - container: "<container-port>"
          description:
            en_US: <what this port is for> (published on host as <host-port>)
      volumes:
        - container: <container-data-path>
          description:
            en_US: <what's stored here>
```

Multi-container apps (DB, cache, relay, etc.) get one service block each,
all under the same `services:` key, sharing the app's port sub-range as a
contiguous block (see `PORT_LEDGER.md`).

**Dynamic variables** (`$TZ`, `$PUID`, `$PGID`, `$PORT`) are required
wherever `VARIABLES.md` says so. The `#` notes in the template above are
for this reference only. They never go in a real manifest (§8).

## 3. Top-level `x-casaos:` block

```yaml
x-casaos:
  id: com.hiraappstore.<appname>   # REQUIRED, reverse-domain, unique
  architectures:
    - amd64
    - arm64
  main: <servicename>              # which service owns port_map/Open
  author: HSinghHira
  category: <one of the fixed categories below>
  developer: <upstream author/org>
  icon: <self-hosted jsdelivr URL — see §5, required>
  # thumbnail: <self-hosted jsdelivr URL — leave commented until captured>
  # screenshot_link:
  #   - <self-hosted jsdelivr URL>
  #   - ...
  title:
    en_US: <App Name>
  tagline:
    en_US: <one-line pitch>
  description:
    en_US: >-
      <1-2 sentence opening paragraph: what it is and its core pitch>


      **Features**


      - <feature 1>
      - <feature 2>
      - <feature 3 — include infra/persistence notes too, e.g.
        "PostgreSQL with pgvector for persistent application data">


      **How to use?**

      1. Open <App Name> from the Zima OS dashboard.
      2. Complete initial setup and create your administrator account
         (if applicable).
      3. <app-specific first action>
      4. <...>
      5. <mention any settings configurable later without rebuilding —
         config file, in-app admin panel, etc.>
  tips:
    before_install:
      en_US: >-
        <see SECRETS.md for exactly what this list must cover>
  index: /
  port_map: "<host-port-of-main-service>"
  scheme: http    # or https if the app terminates TLS
  is_uncontrolled: false
  version: "<upstream version>"        # omit version/update_at/release_notes
  update_at: "<YYYY-MM-DD>"            # together if upstream only publishes
  release_notes:                        # floating tags (latest/main/next) —
    en_US: |-                           # explain why here instead, see §6
      - <what changed in this manifest update>
  repo: "https://github.com/<org>/<repo>"
  support: "https://github.com/<org>/<repo>/issues"
  docs: "https://github.com/<org>/<repo>/tree/main/docs"
```

**Fixed category list** — must match exactly, don't invent a new one:
Media, Productivity, Home, Networking, AI, Finance, Social, Developer,
Others.

**`description` and `tips.before_install` render as markdown** inside the
`en_US:` block scalar — use real markdown links, `**bold**` headers, and
`-`/numbered lists, not flat prose. Leave a blank line between list
items/paragraphs: YAML block scalars fold single newlines into spaces, so
without blank lines the bullets run together into one line.

**`version` / `update_at` / `release_notes`:** include all three whenever
upstream publishes real, pinnable version tags — `version` matches the
pinned tag, `update_at` is the date this manifest was last verified
against it, `release_notes.en_US` is a short bullet list of what changed
in *this manifest*, not upstream's own changelog. Omit all three if
upstream only publishes floating tags — there's no reliable "installed
version" to report — and explain why in `release_notes` instead (see §6).

## 4. Volumes and config

- Data lives under `/DATA/AppData/$AppID` on the host, bind-mounted with
  `create_host_path: true`.
- Prefer environment-variable configuration over mounting a config *file*
  wherever the upstream image supports it. If the file doesn't already
  exist on the host, Docker silently creates an empty **directory** there
  instead, breaking the container in a confusing way that doesn't look
  like a missing-file error. (This is why Ente's SMTP config uses
  `ENTE_SMTP_*` env vars rather than a mounted file.)
- If a file mount is unavoidable, note in `tips.before_install` that the
  file must be pre-created before the container starts — not a comment on
  the volume (see §8).

## 5. Icons and screenshots — always self-hosted, always via jsdelivr

- Download every image into `Apps/<AppName>/` in this repo (`icon.png`,
  `thumbnail.png`, `thumbnail-N.png`, ...).
- Point `labels.icon`, `x-casaos.icon`, `x-casaos.thumbnail`, and
  `x-casaos.screenshot_link` at the jsdelivr CDN mirror of that path —
  **never** raw.githubusercontent.com or upstream's own CDN (if they move,
  rename, or delete the file, the listing breaks silently):

  ```
  https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/<AppName>/<file>
  ```

  Example (Ente's icon):

  ```
  https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/Ente/icon.png
  ```

- `@main` pins the branch (swap only if you deliberately want a different
  ref); `Apps/<AppName>/<file>` must match the committed path exactly,
  case-sensitive.
- `icon` is required and must point at an already-committed file — the
  store won't render without one, so grab/crop an icon before writing the
  manifest.
- `thumbnail` and `screenshot_link` **start out commented out**, not
  filled with a URL to a file that doesn't exist yet — a live field
  pointing at a missing image is a silent broken-image icon in the store
  with no build error to catch it; a commented-out field is an obvious
  TODO. Uncomment once the actual thumbnail/screenshots are captured and
  committed. The **first entry in `screenshot_link` should be the
  thumbnail image itself**, followed by the real screenshots.
- No `<your-username>/<your-repo-name>` placeholders left in anything
  meant to be committed.

## 6. Image tag

- Prefer a pinned version tag over `:latest` if upstream publishes one.
- If upstream only publishes floating tags, say so in
  `x-casaos.release_notes` — not a comment — so future maintainers know
  *why* there's no version tracking, instead of assuming it was an
  oversight.

## 7. Resource limits

Always set `deploy.resources.limits` (cpus + memory) and
`deploy.resources.reservations` (cpus + memory) — don't leave an app
unbounded on a shared box. Size to what upstream docs recommend as a
minimum; pad modestly.

## 8. No comments in `docker-compose.yml`

**Never use `#` comments to explain anything in the file** — not why a tag
is floating, not why a var needs a specific value, not which two services
share a password, not what a port is for. If something needs explaining,
it belongs in a real field the store UI actually shows:

| What needs explaining | Where it goes instead |
|---|---|
| Why an image uses a floating tag | `x-casaos.release_notes` or `description` |
| What an env var is for / what value to use | `x-casaos.envs[].description` |
| What a port is for | `x-casaos.ports[].description` |
| What a volume stores | `x-casaos.volumes[].description` |
| Two services must share a password/value | Both vars' `x-casaos.envs[].description` |
| A file mount that must be pre-created | `tips.before_install`, not a volume comment |

The one exception: temporarily disabling a whole field that isn't ready
yet (`# thumbnail: ...`, `# screenshot_link:` — see §5) is fine, since
that's a placeholder toggle, not an explanation.