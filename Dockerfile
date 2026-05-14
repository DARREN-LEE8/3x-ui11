# ─────────────────────────────────────────────────────────────────────────────
# 3x-ui on Railway
#
# Uses the official pre-built ghcr.io/mhsanaei/3x-ui image and replaces the
# default entrypoint with a lightweight wrapper that:
#   1. Reads Railway's $PORT env var and writes it into the 3x-ui SQLite DB.
#   2. Resets the panel login to admin / admin on every cold start.
#   3. Disables fail2ban (requires CAP_NET_ADMIN which Railway doesn't grant).
# ─────────────────────────────────────────────────────────────────────────────
FROM ghcr.io/mhsanaei/3x-ui:latest

# Disable fail2ban – Railway containers are unprivileged and don't have
# iptables / CAP_NET_ADMIN, so fail2ban would crash the container.
ENV XUI_ENABLE_FAIL2BAN=false

# Store the database in /etc/x-ui (Railway persistent-volume mount point).
# Override XUI_DB_FOLDER in the Railway service settings if you mount a
# volume at a different path.
ENV XUI_DB_FOLDER=/etc/x-ui

# Copy our Railway-specific startup script.
COPY railway-entrypoint.sh /app/railway-entrypoint.sh
RUN chmod +x /app/railway-entrypoint.sh

# Railway routes external HTTPS → $PORT inside the container.
# The panel's actual port is configured at runtime by railway-entrypoint.sh.
EXPOSE 2053

# Override the upstream entrypoint.
ENTRYPOINT ["/app/railway-entrypoint.sh"]
