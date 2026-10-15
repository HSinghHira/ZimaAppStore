# syntax=docker/dockerfile:1.7
#
# AppFlowy all-in-one. Build with ./capture-meta.sh run first (it fills ./meta).
# To bump a version, change the tag on a FROM line below and rebuild.

FROM appflowyinc/appflowy_cloud:0.19.2 AS img-cloud
FROM appflowyinc/appflowy_worker:0.18.8 AS img-worker
FROM appflowyinc/appflowy_search:0.18.8 AS img-search
FROM appflowyinc/gotrue:0.18.8 AS img-gotrue
FROM appflowyinc/admin_frontend:0.18.1 AS img-admin
FROM appflowyinc/appflowy_web:0.19.8 AS img-web
FROM axllent/mailpit:v1.31.4 AS img-mailpit
FROM pgsty/silo:RELEASE.2026-09-16T00-00-00Z AS img-silo

FROM debian:bookworm-slim AS silo-bin
COPY --from=img-silo / /silo-root
RUN set -eu; \
    bin=$(find /silo-root -maxdepth 5 -type f -perm /111 -name minio | head -n1); \
    [ -n "$bin" ] || bin=$(find /silo-root -maxdepth 5 -type f -perm /111 -name 'silo*' | head -n1); \
    [ -n "$bin" ] || { echo "could not find the silo/minio binary in the silo image"; find /silo-root -maxdepth 3 -type f -perm /111 | head -50; exit 1; }; \
    echo "using $bin"; \
    install -D "$bin" /out/silo

FROM debian:bookworm-slim AS rust-bins
COPY --from=img-cloud  / /r/cloud
COPY --from=img-worker / /r/worker
COPY --from=img-search / /r/search
RUN set -eu; \
    mkdir -p /out/app; \
    pick() { \
      svc=$1; shift; bin=""; \
      for pat in "$@"; do \
        bin=$(find "/r/$svc" \( -path "/r/$svc/proc" -o -path "/r/$svc/sys" -o -path "/r/$svc/lib" -o -path "/r/$svc/lib64" -o -path "/r/$svc/usr/lib" -o -path "/r/$svc/usr/share" \) -prune -o -type f -perm /111 -name "$pat" -print | head -n1); \
        if [ -n "$bin" ]; then break; fi; \
      done; \
      if [ -z "$bin" ]; then \
        echo "could not find any of [$*] in the $svc image. Executables there:"; \
        find "/r/$svc" -type f -perm /111 | grep -v -E '/(lib|lib64|usr/lib|usr/libexec|usr/share|etc|var)/' | head -60; \
        exit 1; \
      fi; \
      rel=${bin#/r/$svc}; \
      install -D "$bin" "/out$rel"; \
      echo "$svc: $rel"; \
    }; \
    pick cloud appflowy_cloud appflowy-cloud 'appflowy[_-]cloud*'; \
    pick worker appflowy_worker appflowy-worker 'appflowy[_-]worker*'; \
    pick search appflowy_search appflowy-search 'appflowy[_-]search*'; \
    for n in cloud worker search; do \
      if [ -d "/r/$n/app" ]; then cp -a "/r/$n/app/." /out/app/; fi; \
    done; \
    echo "files under /out/app:"; ls -A /out/app

FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d; \
    mkdir -p /etc/postgresql-common; echo 'create_main_cluster = false' > /etc/postgresql-common/createcluster.conf; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg; \
    install -d /usr/share/keyrings; \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] https://apt.postgresql.org/pub/repos/apt trixie-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        postgresql-16 postgresql-16-pgvector redis-server nginx supervisor jq util-linux procps openssl tzdata; \
    rm -rf /var/lib/apt/lists/*

COPY --from=rust-bins /out/ /
COPY --from=silo-bin  /out/silo /usr/local/bin/silo

COPY --from=img-gotrue  / /opt/rootfs/gotrue/
COPY --from=img-admin   / /opt/rootfs/admin/
COPY --from=img-web     / /opt/rootfs/web/
COPY --from=img-mailpit / /opt/rootfs/mailpit/

COPY meta/ /opt/meta/
COPY aio-init.sh /usr/local/bin/aio-init
COPY run-svc.sh /usr/local/bin/run-svc
COPY supervisord.conf /etc/supervisor/aio.conf
COPY nginx.conf.tpl /etc/nginx/aio.conf.tpl
RUN chmod +x /usr/local/bin/aio-init /usr/local/bin/run-svc

LABEL org.opencontainers.image.title="appflowy-aio" \
      org.opencontainers.image.description="Self-hosted AppFlowy Cloud in a single container" \
      org.opencontainers.image.source="https://github.com/HSinghHira/ZimaAppStore"

EXPOSE 8080
STOPSIGNAL SIGTERM

HEALTHCHECK --interval=30s --timeout=10s --start-period=240s --retries=5 \
  CMD curl -fsS -o /dev/null http://127.0.0.1:8080/api/health || exit 1

ENTRYPOINT ["/usr/local/bin/aio-init"]
