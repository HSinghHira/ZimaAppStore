# PORT_LEDGER.md — Live port assignment table

**Rule: every published port across the whole store must be unique, and
must be ≤ 65535.**

We use an `84xx` block, one 2-digit sub-range per app, assigned in the
order apps were added:

| App | Ports used |
|---|---|
| OmniRoute | 8401 |
| SearXNG | 8402 |
| Ente Photos (MinIO) | 8403 (API), 8404 (Photos web), 8405 (public albums), 8406 (MinIO S3), 8407 (Mailpit) |
| AFFiNE | 8408 |
| Cloudreve | 8409 (web UI/API), 8410 (Aria2 remote-download port, tcp+udp) |
| Mailpit | 8411 (web UI), 8412 (SMTP) |
| NodeCast TV | 8413 |
| Continuwuity (Matrix) | 8414 |
| Dispatcharr | 8415 |
| deGoogle | 8416 |
| Web-Check | 8419 |
| VERT | 8420 |
| WatchYourLAN | 8421 (web UI, on host network — not a published Docker port) |
| Stoat Chat | 8422 (web UI), 8423 (LiveKit voice, tcp), 8424-8429 (LiveKit voice, udp x6) |
| SpiderFoot | 8430 |
| Homelable | 8431 (frontend web UI). Backend has no published port — reached only over the internal homelable_network. |
| Tianji | 8432 |
| GameVault | 8433 |
| Yuvomi | 8434 |
| openGym | 8435 |
| Pocket ID | 8436 |
| Outline | 8437 |
| BookOrbit | 8438 |
| Indelible | 8439 |
| Helix | 8440 |
| ZimaBrain CE | 8441 |
| OmniCloud | 8442 |
| Claude Code Container | 8443 |
| Docmost | 8444 |
| DocuSeal | 8445 |
| Documenso | 8446 |
| SkySend | 8447 |
| Coder | 8448 |
| VS Code | 8449 (HTTP), 8450 (HTTPS) |
| VS Codium Web | 8451 |
| Ente Photos (Garage) | 8452 (API), 8453 (Photos web), 8454 (public albums), 8455 (Garage S3), 8456 (Mailpit) |
| Ente Photos (SeaweedFS) | 8457 (API), 8458 (Photos web), 8459 (public albums), 8460 (SeaweedFS S3), 8461 (Mailpit) |

**Next new app starts at: 8462**

## Rules

- Claim the next unused number(s) in sequence and record them here
  *before* writing the manifest, so two apps in progress at once can't
  collide.
- Multi-container apps (like Ente) get a contiguous mini-block — easier to
  scan `docker ps` and know which app a port belongs to.
- **A 5-digit `840xx`-style range is invalid** — we made this mistake
  once. TCP ports max out at 65535, so anything like `84010`, `84020`
  will fail with `invalid port specification` or break "Open" buttons
  with an "invalid URL" error. Stick to 4-digit `84xx`.
- Support services with no reason to be reachable from outside the Docker
  network (e.g. a Postfix relay only `museum` talks to) don't need a
  published port at all — just put them on the shared internal network.
- If you ever renumber a port, grep the whole app's services for
  `localhost:<old-port>` — any service reaching another over its
  *published* host port (not the internal Docker network) needs that
  reference updated too. Also update the matching badge in
  `PUBLISHING_README.md`'s README row in the same change.
