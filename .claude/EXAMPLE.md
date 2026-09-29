# EXAMPLE.md — one worked submission, start to finish

A fictional single-container app, "PixelNote," walking through every file
in this set in order. The port used (8462) is illustrative only — always
check `PORT_LEDGER.md` for the real next-available port before claiming
one.

## 1. Claim a port (PORT_LEDGER.md)

Add a row: `| PixelNote | 8462 |`, then update "Next new app starts at"
to 8463 — before writing anything else.

## 2. Write docker-compose.yml (ARCHITECTURE.md)

```yaml
name: pixelnote

services:
  pixelnote:
    image: pixelnote/pixelnote:1.4.0
    container_name: pixelnote
    restart: unless-stopped
    stop_grace_period: 40s
    network_mode: bridge
    environment:
      - ADMIN_EMAIL=CHANGEME
      - SECRET_KEY=8f3a1c9e2b4d6f0a1c3e5b7d9f1a3c5e
    ports:
      - target: 3000
        published: "8462"
        protocol: tcp
    volumes:
      - type: bind
        source: /DATA/AppData/$AppID
        target: /data
        bind:
          create_host_path: true
    deploy:
      resources:
        limits:
          cpus: "1.00"
          memory: 512M
        reservations:
          cpus: "0.00"
          memory: 128M
    labels:
      icon: https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/PixelNote/icon.png
    x-casaos:
      id: com.hiraappstore.pixelnote
      envs:
        - container: ADMIN_EMAIL
          description:
            en_US: The email address for the first admin account.
        - container: SECRET_KEY
          description:
            en_US: >-
              Pre-filled with a random value. Replace it with your own —
              generate one at
              [randomkeygen.com](https://randomkeygen.com/) — before
              going live.
      ports:
        - container: "3000"
          description:
            en_US: Web UI (published on host as 8462)
      volumes:
        - container: /data
          description:
            en_US: Notes, attachments, and the SQLite database.

x-casaos:
  id: com.hiraappstore.pixelnote
  architectures:
    - amd64
    - arm64
  main: pixelnote
  author: HSinghHira
  category: Productivity
  developer: PixelNote Team
  icon: https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/PixelNote/icon.png
  thumbnail: https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/PixelNote/thumbnail.png
  screenshot-links:
    - https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/PixelNote/thumbnail-1.png
    - https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/PixelNote/thumbnail-2.png
    - https://cdn.jsdelivr.net/gh/HSinghHira/ZimaAppStore@main/Apps/PixelNote/thumbnail.png
  title:
    en_US: PixelNote
  tagline:
    en_US: Simple self-hosted note-taking with a pixel-art vibe.
  description:
    en_US: >-
      A lightweight, self-hosted note-taking app — think Notion's little
      sibling with a pixel-art theme.


      **Features**


      - Markdown notes with tags and search
      - SQLite storage under /DATA/AppData/$AppID
      - Single-container, no external dependencies


      **How to use?**

      1. Open PixelNote from the Zima OS dashboard.
      2. Complete the initial setup and create your administrator account.
      3. Create your first note from the "+" button.
      4. Manage users later from Settings → Admin.
  tips:
    before_install:
      en_US: >-
        1. Open the app configuration before starting the installation.

        2. Find ADMIN_EMAIL in the pixelnote service.

        3. Set it to the email you want to use as admin.

        4. Find SECRET_KEY in the pixelnote service.

        5. Replace it with your own — generate one at
           [randomkeygen.com](https://randomkeygen.com/) — before going
           live.

        6. Start the PixelNote installation.

        7. Open PixelNote from the Zima OS dashboard.

        8. Create your administrator account.

        9. You can change settings later in Settings → Admin.
  index: /
  port_map: "8462"
  scheme: http
  is_uncontrolled: false
  version: "1.4.0"
  update_at: "2026-09-27"
  release_notes:
    en_US: |-
      - Initial version
  repo: "https://github.com/pixelnote/pixelnote"
  support: "https://github.com/pixelnote/pixelnote/issues"
  docs: "https://github.com/pixelnote/pixelnote/tree/main/docs"
```

Notice: no `#` comments anywhere except the commented-out `thumbnail`
line — everything else lives in an `x-casaos` field.

## 3. Icons (ARCHITECTURE.md §5)

Download PixelNote's icon to `Apps/PixelNote/icon.png` in this repo, then
reference it via the jsdelivr mirror, as shown above. Leave `thumbnail`
commented out until a real screenshot is captured.

## 4. README row (PUBLISHING_README.md)

```markdown
| <h2><img src=Apps/PixelNote/icon.png width=21 height=21> PixelNote</h2> [![tag](https://img.shields.io/badge/pixelnote/pixelnote-latest-blue?style=plastic)](https://github.com/pixelnote/pixelnote) [![tag](https://img.shields.io/badge/visit-project-green?style=plastic)](https://github.com/pixelnote/pixelnote) [![port](https://img.shields.io/badge/port-8462-9cf?style=plastic)]() <br /> A lightweight, self-hosted note-taking app — think Notion's little sibling with a pixel-art theme. |  |
```

Thumbnail cell left blank since none has been captured yet.

## 5. Pre-push checklist

Run `PRE_PUSH_CHECKLIST.md` top to bottom. In this example: YAML is valid,
port 8462 is recorded and non-colliding, `SECRET_KEY` is a generated value
(not `CHANGEME_*`) with a linked description, category `Productivity` is
on the fixed list, icon URL points at this repo's jsdelivr mirror,
`x-casaos.id` is present at both levels, `version`/`update_at`/
`release_notes` all line up, the README row exists, there are no stray
`#` comments, and `tips.before_install` reads at a 4th-grade level.
