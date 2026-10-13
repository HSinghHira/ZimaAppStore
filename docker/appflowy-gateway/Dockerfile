FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="appflowy-gateway" \
      org.opencontainers.image.description="nginx reverse proxy for self-hosted AppFlowy Cloud on ZimaOS" \
      org.opencontainers.image.source="https://github.com/HSinghHira/ZimaAppStore"

# Config is baked in: no heredoc, no @ -> $ substitution at startup.
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget -q -O /dev/null http://127.0.0.1:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
