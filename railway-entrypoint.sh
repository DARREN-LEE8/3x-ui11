#!/bin/bash
set -e

# Railway injects a $PORT env var for the HTTP service.
# 3x-ui stores its panel port in the SQLite database, so we
# read $PORT here and write it into the DB before starting.
PANEL_PORT=${PORT:-2053}

# Credentials can be overridden via Railway environment variables.
# Set XUI_USERNAME and XUI_PASSWORD in Railway → Service → Variables.
# Defaults to admin/admin for convenience; change these for any
# internet-facing deployment.
PANEL_USERNAME=${XUI_USERNAME:-admin}
PANEL_PASSWORD=${XUI_PASSWORD:-admin}

# Ensure the database directory exists.
mkdir -p "${XUI_DB_FOLDER:-/etc/x-ui}"

echo "[railway-entrypoint] Configuring 3x-ui panel port=${PANEL_PORT}, user=${PANEL_USERNAME}"

# Apply port + credentials to the database (creates the DB if it does not
# exist yet). Credentials are applied on every cold start so the panel
# always reflects the values of XUI_USERNAME / XUI_PASSWORD.
/app/x-ui setting \
    -username "${PANEL_USERNAME}" \
    -password "${PANEL_PASSWORD}" \
    -port "${PANEL_PORT}" 2>/dev/null || true

echo "[railway-entrypoint] Starting 3x-ui..."
exec /app/x-ui
