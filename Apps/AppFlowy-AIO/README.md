# AppFlowy AIO (All-in-One) Configuration & Environment Variables

AppFlowy AIO packages the entire AppFlowy Cloud stack into a single Docker container. This includes:
* **Nginx Gateway** (internal port `8080`, published to host as **`8481`**)
* **PostgreSQL 16 with pgvector** (database)
* **Redis** (caching and pub/sub)
* **Silo** (MinIO/S3-compatible file storage)
* **GoTrue** (Supabase authentication engine)
* **AppFlowy Cloud Backend** (Rust API & WebSocket server)
* **AppFlowy Worker** (Background tasks & import processor)
* **AppFlowy Search** (Full-text keyword indexer)
* **AppFlowy Web App** (Collaborative web frontend)
* **Admin Frontend** (User and workspace management portal)
* **Mailpit** (Local SMTP server and webmail viewer)

---

## 🌐 Network Ports & URL Endpoints

By default, only one port is published on the host: **`8481`**.

| Endpoint | Subpath | Description |
| :--- | :--- | :--- |
| **Web App** | `/` | AppFlowy collaborative web frontend |
| **API** | `/api` | Cloud backend REST API |
| **WebSockets** | `/ws` (or `/ws/v2`) | Real-time page sync and collaboration |
| **Auth** | `/gotrue` | GoTrue authentication service |
| **Admin Console** | `/console` | Admin management portal |
| **Mailpit Web UI** | `/mail/` | Local webmail viewer for confirmation/invite emails |
| **Storage Console** | `/minio/` | Silo / MinIO bucket storage console |
| **S3 API** | `/minio-api/` | Presigned asset uploads and file downloads |

> [!IMPORTANT]
> The internal gateway listens on port `8080`, but the host publishes it as port **`8481`**.
> Always use `http://<YOUR-IP>:8481` (e.g., `http://192.168.68.13:8481/mail/`), **not** port `8080`.

---

## ⚙️ Environment Variables Reference

You can configure these variables in your `docker-compose.yml` or through the ZimaOS / CasaOS web interface under container settings.

### 1. Core Settings

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `TZ` | `$TZ` (or `UTC`) | Container timezone (e.g., `America/New_York`, `UTC`). |
| `PUBLIC_URL` | `http://localhost:8481` | The public URL clients and browsers use to reach AppFlowy. For local LAN access, set to `http://<ZIMAOS-IP>:8481`. For domain/SSL access, set to `https://appflowy.yourdomain.com`. |
| `ADMIN_EMAIL` | `CHANGEME@example.com` | Email address for the initial administrator account. |
| `ADMIN_PASSWORD` | *(auto-generated)* | Initial admin password. If left blank, a secure random password is generated on first startup and logged in container output. |
| `AIO_DATA` | `/data` | Path inside the container for persistent storage. |
| `AIO_SKIP_WAIT` | `0` | Set to `1` to bypass service readiness checks during container startup. |
| `AIO_DRY_RUN` | `0` | Set to `1` to generate configuration and exit without starting services. |

---

### 2. Email & SMTP Configuration

AppFlowy AIO includes **Mailpit** by default to capture all outgoing emails (invites, password resets, email verification) without needing external credentials. All mail can be viewed at `http://<ZIMAOS-IP>:8481/mail/`.

To route email through an external SMTP provider (such as Gmail, Resend, Brevo, SendGrid, Amazon SES):

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `SMTP_HOST` | `appflowy-mailpit` | External SMTP hostname (e.g., `smtp.gmail.com`, `smtp.resend.com`). |
| `SMTP_PORT` | `1025` | SMTP port (e.g., `587` for STARTTLS, `465` for SSL/TLS, `1025` for Mailpit). |
| `SMTP_USER` | *(empty)* | SMTP username / account email. |
| `SMTP_PASS` | *(empty)* | SMTP password or app-specific token. |
| `SMTP_EMAIL` | `noreply@appflowy.local` | Sender address shown in the "From" field. |
| `SMTP_TLS` | `none` | TLS mode for AppFlowy Cloud backend: `none`, `required`, or `wrapper` (use `wrapper` for port 465). |

*(Alternatively, standard aliases like `GOTRUE_SMTP_*` and `APPFLOWY_MAILER_SMTP_*` are also supported and take precedence if provided).*

#### Mailpit Web UI & Security (`MP_*` Variables)

Any environment variable prefixed with `MP_` is forwarded to Mailpit:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `MP_UI_AUTH` | *(none)* | Enable HTTP Basic Authentication for `/mail/`. Format: `username:password` (e.g., `admin:admin` or multiple pairs: `"user1:pass1 user2:pass2"`). |
| `MP_MAX_MESSAGES` | `500` | Maximum number of emails kept in memory. |
| `MP_DATA_FILE` | *(none)* | Optional path to persist emails to SQLite database instead of RAM (e.g., `/data/mailpit.db`). |

---

### 3. Authentication (GoTrue) Variables

All variables prefixed with `GOTRUE_` can be passed to tune the authentication engine:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `GOTRUE_DISABLE_SIGNUP` | `false` | Set to `true` to disable new user registrations. |
| `GOTRUE_MAILER_AUTOCONFIRM` | `true` | When `true`, user accounts are automatically confirmed upon signup without waiting for email verification clicks. Set to `false` if using a real SMTP server. |
| `GOTRUE_SITE_URL` | `appflowy-flutter://` | Base redirect URL for desktop and mobile native apps. |
| `GOTRUE_URI_ALLOW_LIST` | `**` | Comma-separated list of allowed wildcard callback URLs for authentication redirects. |
| `GOTRUE_JWT_EXP` | `604800` | JWT access token lifetime in seconds (default is 7 days). |
| `GOTRUE_RATE_LIMIT_EMAIL_SENT` | `100` | Maximum number of emails sent per hourly window. |
| `GOTRUE_SMTP_MAX_FREQUENCY` | `1ns` | Cooldown period between successive authentication emails. |

---

### 4. AppFlowy Cloud Backend Variables

Any environment variable prefixed with `APPFLOWY_` is automatically forwarded to the backend cloud service:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `RUST_LOG` | `info` | Rust log verbosity (`error`, `warn`, `info`, `debug`, `trace`). |
| `APPFLOWY_ENVIRONMENT` | `production` | Deployment environment name. |
| `APPFLOWY_ACCESS_CONTROL` | `true` | Enable workspace and document permission controls. |
| `APPFLOWY_DATABASE_MAX_CONNECTIONS` | `40` | Maximum database connection pool size. |
| `SIGNUP_WHITELIST_ENABLED` | `false` | When `true`, only email addresses matching the admin whitelist can sign up. |
| `GUEST_INVITES_REQUIRE_ADMIN_APPROVAL` | `false` | When `true`, invites sent to guests require administrator approval. |
| `AI_ENABLED` | `false` | Enable AI companion features (requires separate AI service configuration). |
| `APPFLOWY_SEARCH_REQUEST_TIMEOUT_SECS` | `10` | Timeout in seconds for search queries forwarded to the search engine. |

---

### 5. AppFlowy Worker & Search Variables

Any variable prefixed with `APPFLOWY_WORKER_` is passed to the background worker service:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `APPFLOWY_WORKER_IMPORT_TICK_INTERVAL` | `30` | Interval in seconds for processing import queues. |
| `APPFLOWY_BACKGROUND_INDEXER_ENABLED` | `true` | Run search indexing in background worker. |
| `APPFLOWY_KEYWORD_SEARCH_ENABLED` | `true` | Enable keyword full-text search indexing. |
| `APPFLOWY_KEYWORD_WORKER_ENABLED` | `true` | Enable search worker queue. |
| `APPFLOWY_KEYWORD_INDEX_MAP_SIZE_BYTES` | `2147483648` | Memory map allocation for Tantivy search indexer (2 GB). |

---

## 🛠️ Advanced Per-Service Overrides

If you need to inject custom environment variables directly into any individual service without altering the primary Docker environment, you can drop `.env` override files into the persistent data folder on the host:

```text
/DATA/AppData/$AppID/data/state/overrides/<service>.env
```

Available service names:
* `cloud.env` (AppFlowy Cloud backend)
* `worker.env` (AppFlowy Worker)
* `search.env` (AppFlowy Search)
* `gotrue.env` (GoTrue auth service)
* `admin.env` (Admin frontend portal)
* `web.env` (Web frontend)
* `silo.env` (MinIO/Silo storage)
* `mailpit.env` (Mailpit email service)

Any variable declared in these files will be loaded on container restart.

---

## 🔒 Secret Keys & Database Passwords

On the first start, AppFlowy AIO automatically generates unique cryptographically secure secrets:
* `PG_PASSWORD` (PostgreSQL password)
* `S3_ACCESS_KEY` & `S3_SECRET_KEY` (Silo/MinIO storage credentials)
* `JWT_SECRET` (GoTrue & AppFlowy signing key)
* `ADMIN_PASSWORD` (Initial admin password, if not explicitly provided)

These keys are persisted inside `/data/state/secrets.env` (host path `/DATA/AppData/$AppID/data/state/secrets.env`). Do not delete this file or existing database connections will fail.

---

## 🌐 Reverse Proxy (Cloudflare Tunnel / Nginx / Caddy)

When exposing AppFlowy AIO to the internet:

1. **Set `PUBLIC_URL`:**
   Configure `PUBLIC_URL` with your full HTTPS URL, e.g.:
   ```env
   PUBLIC_URL=https://test1.hira.im
   ```
2. **Reverse Proxy Target Port:**
   Point your reverse proxy upstream to host port **`8481`** (e.g., `http://192.168.68.13:8481`), **NOT** port `8080`.
3. **WebSockets:**
   Ensure WebSocket upgrade headers are passed:
   ```nginx
   proxy_http_version 1.1;
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection "upgrade";
   ```
4. **Header Forwarding:**
   Pass client protocol and host headers:
   ```nginx
   proxy_set_header Host $http_host;
   proxy_set_header X-Real-IP $remote_addr;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   proxy_set_header X-Forwarded-Proto $scheme;
   ```

---

## ❓ Troubleshooting

### 1. `ERR_CONNECTION_REFUSED` on port `8080`
* **Cause:** Connecting to `http://<IP>:8080` instead of port `8481`.
* **Fix:** Connect to `http://<IP>:8481` (e.g. `http://192.168.68.13:8481/mail/`).

### 2. `signUpWithPassword: failed {status: undefined, code: -1}`
* **Cause:** The browser cannot reach the `/gotrue` endpoint.
* **Fix:**
  * If using a reverse proxy, ensure it forwards to port **`8481`** and passes all subpaths.
  * Check that `PUBLIC_URL` matches your access scheme (use `https://` if accessing through SSL).
  * Open DevTools (**F12**) $\rightarrow$ **Network** $\rightarrow$ `Fetch/XHR` to view the specific network error on `/gotrue/signup`.
