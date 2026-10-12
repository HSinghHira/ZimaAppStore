# PUBLISHING_README.md — root README.md app table

The root `README.md` has a single markdown table listing every app, kept
in the same order as `PORT_LEDGER.md`. Add or update a row here for every
app you touch — this is a separate step from the manifest, easy to
forget, and there's no build error if you skip it.

## Row format

```markdown
| <h2><img src=https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/<AppName>/icon.png width=21 height=21> <App Name></h2> [![tag](https://img.shields.io/badge/<org>/<repo>-latest-blue?style=plastic)](https://github.com/<org>/<repo>) [![tag](https://img.shields.io/badge/visit-project-green?style=plastic)](<upstream homepage or repo URL>) [![<port label>](https://img.shields.io/badge/<port label>-<port>-9cf?style=plastic)]() <br /> <1–2 sentence description matching the manifest's opening pitch>. | <img src="https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/<AppName>/thumbnail.png" width="1200" alt="<App Name> preview"> |
```

Real example (FluxDown):

```markdown
| <h2><img src=https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/FluxDown/icon.png width=21 height=21> FluxDown</h2> [![tag](https://img.shields.io/badge/zerx--lab/fluxdown--server-latest-blue?style=plastic)](https://github.com/zerx-lab/FluxDown) [![tag](https://img.shields.io/badge/visit-project-green?style=plastic)](https://github.com/zerx-lab/FluxDown) [![port](https://img.shields.io/badge/port-8470-9cf?style=plastic)]() <br /> A fast, self-hosted download manager powered by a Rust engine. It handles HTTP/HTTPS, FTP, BitTorrent, HLS and more, with resume and speed control. | <img src="https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/FluxDown/thumbnail.png" width="1200" alt="FluxDown preview"> |
```

## Rules

- **Icon and thumbnail paths** — both use the jsdelivr mirror
  (`https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/<AppName>/<file>`),
  never a relative `Apps/...` path. This matches `ARCHITECTURE.md` §5.
  If `<AppName>` contains a space, URL-encode it as `%20` in *both* the
  icon `<img src=...>` and the thumbnail `src` (see NodeCast TV). Raw
  spaces break the image on some renderers because the space is read as
  the end of the `src`/URL.
- **Tag badges** — same two badges every row: the image repo (`blue`)
  linking to the GitHub repo, and `visit-project` (`green`) linking to
  the upstream homepage (or the repo again if there's no separate site).
- **Port badge(s)** — one `9cf` (light-blue) badge per published port,
  using the same host port committed in `PORT_LEDGER.md`. Label each
  badge with what the port is for, matching the ledger's wording:
  - Single-port app: `[![port](https://img.shields.io/badge/port-<port>-9cf?style=plastic)]()`
  - Multi-port app: one badge per port, labeled (e.g. `API`, `Web`,
    `web_UI`, `SMTP`) instead of the generic `port` label — see Ente,
    Mailpit, Cobalt, Cloudreve for examples. Use `_` instead of spaces in
    multi-word badge labels (shields.io renders `_` as a space); use
    `%2F` for a literal `/` in a label like `web/API`.
  - A port that needs a non-numeric qualifier (Cloudreve's Aria2 port is
    `tcp+udp`) gets that noted as plain italic text *next to* the badge,
    not crammed into the badge label — special characters in badge label
    segments need their own URL-escaping and render inconsistently.
  - These badges link to nothing (`()`) since there's no useful target
    for a bare port number — that's expected, don't leave a stray link
    URL here.
- **Support services with no published port** (e.g. the Postfix relay)
  don't get their own row — call them out in a short note under the table
  instead, matching the "no published port" line they already have in
  `PORT_LEDGER.md`.
- **Description** — reuse the manifest's `description` opening pitch (the
  1–2 sentence paragraph before `**Features**`), not the full
  feature/how-to-use text — the table cell is meant to stay short.
- **Thumbnail column** — never leave it blank. Always fill it with
  `<img src="https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/<AppName>/thumbnail.png" width="1200" alt="<App Name> preview">`.
  The `alt` text is the app's display name followed by ` preview`. The
  `thumbnail.png` file must be committed at `Apps/<AppName>/thumbnail.png`
  in the same PR, so say so in `REPO_UPDATES.md` if the image hasn't been
  captured yet. (The manifest's own `x-casaos.thumbnail` line stays
  commented out until the file exists — see `ARCHITECTURE.md` §5. The
  README row does not wait.)

## Keeping the table and the ledger in sync

- Row order in the README should match the order apps were added in
  `PORT_LEDGER.md`.
- If you renumber a port in the ledger, update the matching badge in the
  README row in the same change.
- If an app gains or loses a published port (e.g. a new sidecar service),
  update both the ledger *and* the README badges together.
