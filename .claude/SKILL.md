

Checklist distilled from getting OmniRoute, SearXNG, and Ente working. Follow
this in order for every new app — most of these were real, specific failures
we hit and fixed, not theoretical concerns. Give this whole file to an AI
along with the upstream app's name/image/ports/env vars and it has
everything it needs to produce a compliant `docker-compose.yml` and publish
it correctly.

---



**Rule: every published port across the whole store must be unique, and
must be ≤ 65535.**

We use a `84xx` block, one 2-digit sub-range per app, assigned in the order
apps were added:

| App | Ports used |
|---|---|
| OmniRoute | 8401 |
| SearXNG | 8402 |
| Ente | 8403 (API), 8404 (Photos web), 8405 (public albums), 8406 (MinIO S3), 8407 (Mailpit) |
| *(support services)* | Postfix relay — internal only, no published port |
| AFFiNE | 8408 |
| Cloudreve | 8409 (web UI/API), 8410 (Aria2 remote-download port, tcp+udp) |
| Mailpit | 8411 (web UI), 8412 (SMTP) |
| NodeCast TV | 8413 |
| Continuwuity (Matrix) | 8414 |
| Dispatcharr | 8415 |
| deGoogle | 8416 |
| Cobalt | 8417 (API), 8418 (Web) |
| **Next new app starts at** | **8419** |

- Claim the next unused number(s) in sequence and record them in this table
  *before* writing the manifest, so two apps in progress at once can't
  collide.
- Multi-container apps (like Ente) get a contiguous mini-block — easier to
  scan `docker ps` and know which app a port belongs to.
- **A 5-digit `840xx`-style range is invalid** — we made this mistake once.
  TCP ports max out at 65535, so anything like `84010`, `84020` etc. will
  fail with `invalid port specification` or break "Open" buttons with an
  "invalid URL" error. Stick to 4-digit `84xx`.
- Support services with no reason to be reachable from outside the Docker
  network (e.g. a Postfix relay only `museum` talks to) don't need a
  published port at all — just put them on the shared internal network.
- If you ever renumber a port, grep the whole app's services for
  `localhost:<old-port>` — any service reaching another over its
  *published* host port (not the internal Docker network) needs that
  reference updated too.





```yaml
name: <appname>          
                          
                          

services:
  <appname>:              
    ...

x-casaos:                 
  id: com.hiraappstore.<appname>
  ...
```



For every service (not just the "main" one):

```yaml
services:
  <servicename>:
    image: <org>/<repo>:<tag>   
                                 
                                 
                                 
                                 
    container_name: <servicename>
    restart: unless-stopped
    stop_grace_period: 40s       
                                  
    network_mode: bridge         
                                  
    environment:
      - SOME_VAR=CHANGEME        
    ports:                       
      - target: <container-port>
        published: "<host-port>" 
                                  
        protocol: tcp
    volumes:
      - type: bind
        source: /DATA/AppData/$AppID
        target: <container-data-path>
        bind:
          create_host_path: true
    deploy:
      resources:
        limits:
          cpus: "<n>"
          memory: <n>M
        reservations:
          cpus: "0.00"
          memory: <n>M
    labels:
      icon: <self-hosted icon URL — section 3>
    x-casaos:
      id: com.hiraappstore.<appname>   
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
contiguous block.



```yaml
x-casaos:
  id: com.hiraappstore.<appname>      
                                       
                                       
                                       
  architectures:
    - amd64
    - arm64
  main: <servicename>                 
  author: HSinghHira
  category: <must exist in category-list.json — check before using>
  developer: <upstream author/org>
  icon: <self-hosted jsdelivr URL — section 3, required>
  
  
  
  
  title:
    en_US: <App Name>
  tagline:
    en_US: <one-line pitch>
  description:
    en_US: >-
      <1-2 sentence opening paragraph: what it is and its core pitch,
      e.g. "think X and Y combined.">


      **Features**


      - <feature 1>

      - <feature 2>

      - <feature 3 — include infra/persistence notes here too, e.g.
        "PostgreSQL with pgvector for persistent application data",
        "Persistent storage under /DATA/AppData/$AppID">

      - <...>


      **How to use?**

      1. Open <App Name> from the ZimaOS dashboard.

      2. Complete the initial setup and create your administrator account
         (if applicable).

      3. <app-specific first action, e.g. "Sign in to your workspace">

      4. <app-specific next action>

      5. <...>

      6. <mention any settings that can be configured later without
         rebuilding the container, and where — config file, in-app admin
         panel, etc.>
  tips:
    before_install:
      en_US: >-
        1. <first setup step, e.g. "Open the app configuration before
           starting the installation.">

        2. <find every CHANGEME_* placeholder, name the exact services/vars>

        3. <replace with a real value — note if it must match across
           services, e.g. a shared DB password>

        4. <confirm consistency before starting install, if applicable>

        5. Start the <App Name> installation.

        6. <wait for any migration/setup job to finish before first use,
           if applicable>

        7. Open <App Name> from the ZimaOS dashboard.

        8. <first-run account/setup step, if applicable>

        9. <note where further config lives post-install — config file
           path and/or in-app admin panel>

        10. <call out any one-way/gotcha steps, e.g. "Important: changing
            an env var later does not change an already-initialized DB
            password; a manual reset is required.">
  index: /
  port_map: "<host-port-of-main-service>"
  scheme: http                        
  is_uncontrolled: false
  version: "<upstream version, e.g. 1.0>"   
  update_at: "<YYYY-MM-DD>"                 
                                             
                                             
  release_notes:
    en_US: |-
      - <what changed in this manifest update, one bullet per change>
  repo: "https://github.com/<org>/<repo>"
  support: "https://github.com/<org>/<repo>/issues"
  docs: "https://github.com/<org>/<repo>/tree/main/docs"  
```

Standard fields to always fill in: `architectures`, `main` (which service
is the "primary" one for port_map/open-button purposes), `author`,
`category`, `developer`, `icon`, `title`, `tagline`, `description`,
`port_map`, `scheme`, `index`.

**`description` and `tips.before_install` style:** write these as
markdown inside the `en_US:` block scalar (`>-` or `|-`), not as flat
prose:
- `description` opens with a short pitch paragraph, then a `**Features**`
  section as a `-` bullet list (fold in persistence/infra notes as their
  own bullets — DB engine, cache, where data lives), then a
  `**How to use?**` numbered walkthrough from first open to "everything's
  configured."
- `tips.before_install` is a single numbered list covering the full
  install-to-first-use sequence, not just pre-install prep: placeholder
  values to replace (name the exact `CHANGEME_*` vars and which services
  they're in), any password/value that must match across services, when
  to wait for a migration job, first-run account setup, where post-install
  config lives, and any one-way gotchas (e.g. env vars that only apply at
  DB init time and can't be changed by editing the compose file later).
- **Keep `tips.before_install` language simple — write it like you're
  explaining it to a 4th grader.** Short sentences, everyday words, one
  instruction per numbered step. Don't over-explain: no restating why a
  design decision was made, no digressions into how something works
  internally, no hedging or caveats piled onto a single step. If a step
  needs a "why," give it in five words or fewer, not a clause. Say "Set
  `DB_PASSWORD` to a password you make up" — not "Set `DB_PASSWORD` to a
  strong, unique password of your choosing, which will be used to
  authenticate the application's connection to the underlying database."
- Leave a blank line between list items/paragraphs inside the block
  scalar — YAML block scalars fold single newlines into spaces, so
  without blank lines the bullets/numbers run together into one line.

**`version` / `update_at` / `release_notes`:**
- Include these whenever upstream publishes real, pinnable version tags
  (or you've chosen to pin to a specific tag/digest yourself). `version`
  matches the pinned tag, `update_at` is the date this manifest was last
  verified against that version (`YYYY-MM-DD`), and `release_notes.en_US`
  is a short bullet list of what changed in *this manifest*, not
  upstream's own changelog (e.g. "Initial version", "Bumped to v1.2,
  added REDIS_URL var").
- **Omit all three** if upstream only publishes floating tags
  (`latest`/`main`/`next`) with no versioned Docker tags to pin against —
  there's no reliable "installed version" to report. Explain why in
  `x-casaos.release_notes` instead (per 1g — no comments), and add the
  fields once upstream starts tagging releases.



- Data lives under `/DATA/AppData/$AppID` on the host, bind-mounted with
  `create_host_path: true`.
- Prefer environment-variable configuration over mounting a config *file*
  wherever the upstream image supports it. If a file doesn't already exist
  on the host, Docker silently creates an empty **directory** there
  instead, breaking the container in a confusing way that doesn't look
  like a missing-file error. This is why Ente's SMTP config uses
  `ENTE_SMTP_*` env vars rather than a mounted YAML file.
- If a file mount is unavoidable, note in `tips.before_install` that the
  file must be pre-created (or created by an init step) before the
  container starts — not a comment on the volume (per 1g).



- Prefer a pinned version tag over `:latest` if upstream publishes one.
- If upstream only publishes floating tags, say so in `x-casaos.release_notes`
  (per 1g — no comments) so future maintainers know *why* there's no
  version tracking, instead of assuming it was an oversight.



- Always set `deploy.resources.limits` (cpus + memory) and
  `deploy.resources.reservations` (cpus + memory) — don't leave an app
  unbounded on a shared box. Size to what the upstream docs recommend as a
  minimum; pad modestly.



**Never use `
is floating, not why a var needs a specific value, not which two services
share a password, not what a port is for. If something needs explaining,
it belongs in a real field the store UI actually shows, not a comment
nobody but a repo browser will ever read:

- Why an image uses a floating tag instead of a pinned version → say it in
  `x-casaos.release_notes` or the `description` block, not a comment above
  `image:`.
- What an env var is for / what value to put there → `x-casaos.envs[].description`.
- What a port is for → `x-casaos.ports[].description`.
- What a volume stores → `x-casaos.volumes[].description`.
- Two services that must share a password/value → say so in both vars'
  `x-casaos.envs[].description` ("must match `OTHER_VAR` in the `db`
  service"), not a comment.
- A file mount that must be pre-created before the container starts →
  put that step in `tips.before_install`, not a comment on the volume.

The one exception: temporarily disabling a whole field that isn't ready
yet (`
since that's a placeholder toggle, not an explanation. Everything else
that would previously have been "add a comment saying..." now means "add
a sentence to the matching `x-casaos` description field instead."



- **Top-level `name:`** — e.g. `name: omniroute`. Missing this caused Ente
  to not appear in the store at all with no error message. Every app's
  `docker-compose.yml` needs this.
- **`x-casaos.id`** — reverse-domain style, e.g. `com.hiraappstore.<appname>`.
  The build action (`IceWhaleTech/build-appstore-action`) hard-fails without
  it. Add it to the top-level `x-casaos:` block; mirroring it into each
  service-level `x-casaos:` block too is harmless and keeps things
  consistent.



- Download every image into `Apps/<AppName>/` in this repo (`icon.png`,
  `thumbnail.png`, `thumbnail-N.png`, ...).
- Point `labels.icon` (service level) and `x-casaos.icon` /
  `x-casaos.thumbnail` / `x-casaos.screenshot_link` (top level) at the
  jsdelivr CDN mirror of that path, **not** a raw.githubusercontent.com
  URL — this is the convention used across OmniRoute, SearXNG, and Ente,
  so keep new apps consistent with it:

  ```
  https:
  ```

  Example (Ente's icon):

  ```
  https:
  ```

  Pattern: `@main` pins the branch (swap only if you deliberately want a
  different ref), then `Apps/<AppName>/<file>` matches the path you
  committed the image to exactly — case-sensitive.
- Never point at the upstream project's own repo/CDN for these — if they
  move, rename, or delete the file, the store listing breaks silently.
- No `<your-username>/<your-repo-name>` placeholders left in anything
  meant to be committed.
- **`icon` is required and must point at a real, already-committed file** —
  the store won't render without one, so grab/crop an icon before writing
  the manifest.
- **`thumbnail` and `screenshot_link` should start out commented out**,
  not filled with a URL to a file that doesn't exist yet. A live field
  pointing at a missing image is a silent broken-image icon in the store
  with no build error to catch it; a commented-out field is an obvious
  TODO. Uncomment and fill in once the actual thumbnail/screenshots are
  captured and committed to `Apps/<AppName>/`. The **first entry in
  `screenshot_link` should be the thumbnail image itself**, followed by
  the real screenshots:

  ```yaml
  icon: https:
  
  
  
  
  
  ```



**Nothing personal (real email, real API keys, real passwords) goes in the
repo — ever.** This store is public, so:

- Any credential the app needs (SMTP login, API keys, DB passwords) ships
  as a `CHANGEME_*` placeholder in `environment:`, with a matching
  `x-casaos.envs[].description` explaining what to put there and why.
- If the app needs an external service to function fully (e.g. real email
  sending), prefer bundling a **generic, self-contained relay/service**
  (see Ente's `postfix` service) over hardcoding one provider's config.
  Installers bring their own credentials at install time; the repo stays
  provider-agnostic.
- Passwords that must match across two services (e.g. DB password shared
  between an app and its Postgres container) get that noted in both vars'
  `x-casaos.envs[].description` (e.g. "must match `POSTGRES_PASSWORD` in
  the `db` service"), per 1g — not a comment in the file.



- **YAML validity** — run every manifest through a YAML parser before
  committing. A syntax error won't always fail loudly.
- **File vs. directory bind mounts** — see 1d above.
- **Cross-referenced `localhost` URLs** — see section 0's port-renumbering
  note.
- every `category:` Choose one category from: Media, Productivity, Home, Networking, AI, Finance, Social, Developer, Others



The root `README.md` has a single markdown table listing every app, kept in
the same order as the port ledger in section 0. Add or update a row here
for every app you touch — this is a separate step from the manifest, easy
to forget, and there's no build error if you skip it.



```markdown
| <h2><img src=Apps/<AppName>/icon.png width=21 height=21> <App Name></h2> [![tag](https:
```

- **Icon path** — if `<AppName>` contains a space, URL-encode it as `%20`
  in *both* the `<img src=...>` attribute and the thumbnail path (see
  NodeCast TV). Raw spaces break the image on some renderers because the
  space is read as the end of the `src`/URL.
- **`tag` badges** — same two badges every row: the image repo (`blue`)
  linking to the GitHub repo, and `visit-project` (`green`) linking to the
  upstream homepage (or the repo again if there's no separate site).
- **Port badge(s)** — one `9cf` (light-blue) badge per published port,
  using the same host port committed in the section 0 ledger. Label each
  badge with what the port is for, matching the ledger's wording:
  - Single-port app: `[![port](https:
  - Multi-port app: one badge per port, labeled (e.g. `API`, `Web`,
    `web_UI`, `SMTP`) instead of the generic `port` label — see Ente,
    Mailpit, Cobalt, Cloudreve for examples. Use `_` instead of spaces in
    multi-word badge labels (shields.io renders `_` as a space); use
    `%2F` for a literal `/` in a label like `web/API`.
  - A port that needs a non-numeric qualifier (Cloudreve's Aria2 port is
    `tcp+udp`) gets that noted as plain italic text *next to* the badge,
    not crammed into the badge label — special characters in badge label
    segments need their own URL-escaping and render inconsistently.
  - These badges link to nothing (`()`) since there's no useful target for
    a bare port number — that's expected, don't leave a stray link URL in
    here.
- **Support services with no published port** (e.g. the Postfix relay)
  don't get their own row — call them out in a short note under the table
  instead (see the note under Ente's row area), matching the "no published
  port" line they already have in the section 0 ledger.
- **Description** — reuse the manifest's `description` opening pitch
  (the 1–2 sentence paragraph before `**Features**`), not the full
  feature/how-to-use text — the table cell is meant to stay short.
- **Thumbnail column** — `![thumbnail](Apps/<AppName>/thumbnail.png)`, or
  leave the cell blank (like Continuwuity) if no thumbnail has been
  captured yet. Don't point this at a file that doesn't exist in the repo
  — same silent-broken-image problem as section 3's manifest thumbnails.



- Row order in the README should match the order apps were added in the
  section 0 port ledger.
- If you renumber a port in the ledger (section 0), update the matching
  badge in the README row in the same change.
- If an app gains or loses a published port (e.g. a new sidecar service),
  update both the ledger *and* the README badges together.



1. Validate YAML for every changed/new `docker-compose.yml`.
2. Confirm the port table in section 0 is updated and non-colliding.
3. Confirm no personal secrets anywhere in the diff.
4. Confirm `category:`.
5. Confirm icon/thumbnail/screenshot URLs point at this repo, not upstream.
6. Confirm `x-casaos.id` is present at the top level (and mirrored into
   each service's `x-casaos:` block).
7. If `version`/`update_at`/`release_notes` are present, confirm `version`
   matches the actually-pinned image tag and `release_notes` reflects
   *this* change (not just copy-pasted from the last app).
8. Confirm `README.md` has a matching row (icon, tags, port badge(s),
   description, thumbnail) for every app added or changed, per section 7.
9. Confirm `docker-compose.yml` has no explanatory `
   (per 1g) — only the allowed commented-out placeholder fields
   (`thumbnail`/`screenshot_link`) may remain.
10. Read `tips.before_install` back and confirm it's written in simple,
    4th-grade-level language — short sentences, no over-explaining.