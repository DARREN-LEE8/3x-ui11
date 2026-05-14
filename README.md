# 3x-ui on Railway

Deploy the [3x-ui](https://github.com/MHSanaei/3x-ui) Xray panel on [Railway](https://railway.app) in one click.

## Quick deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/new?template=https%3A%2F%2Fgithub.com%2FDARREN-LEE8%2F3x-ui11)

Or connect this repository manually in the Railway dashboard → **New Project → Deploy from GitHub repo**.

## Default credentials

| Field    | Value   |
|----------|---------|
| Username | `admin` |
| Password | `admin` |

> **Change these immediately** after your first login via *Panel Settings → User Settings*.

## How it works

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds from the official `ghcr.io/mhsanaei/3x-ui` image and swaps in a Railway-aware entrypoint. |
| `railway-entrypoint.sh` | Reads Railway's `$PORT` env var, writes it to the SQLite DB, sets admin/admin credentials, then starts `x-ui`. |
| `railway.toml` | Tells Railway to use the Dockerfile and sets the health-check path. |

## Environment variables

Set these in **Railway → Service → Variables**:

| Variable | Default | Description |
|----------|---------|-------------|
| `XUI_USERNAME` | `admin` | Panel login username. **Set this to a strong value.** |
| `XUI_PASSWORD` | `admin` | Panel login password. **Set this to a strong value.** |
| `XUI_ENABLE_FAIL2BAN` | `false` | Keep `false` – Railway containers are unprivileged. |
| `XUI_DB_FOLDER` | `/etc/x-ui` | Directory for the SQLite database. Must match your volume mount path. |
| `XUI_LOG_LEVEL` | `info` | Log verbosity: `debug`, `info`, `warning`, `error`. |

> `XUI_USERNAME` and `XUI_PASSWORD` are applied to the database on **every** container start. Change them in Railway variables rather than inside the panel to ensure they survive redeploys.

## Persistent storage

Railway resets the container filesystem on every redeploy.  
To keep your inbounds and settings across deploys, add a **Volume** in the Railway service and mount it at `/etc/x-ui` (or whatever `XUI_DB_FOLDER` points to).

> Without a volume, the panel resets to `admin / admin` on every redeploy (credentials set by `railway-entrypoint.sh`).

## Ports

| Port | Service |
|------|---------|
| Railway `$PORT` (auto-assigned) | 3x-ui web panel (proxied by Railway's HTTPS edge) |

The entrypoint automatically configures 3x-ui to listen on Railway's assigned port, so you do not need to set the port manually.

## Notes

- **fail2ban is disabled** because Railway containers run without `CAP_NET_ADMIN` (no iptables).
- **Subscription server** (default port 2096) cannot be reached through Railway's standard HTTP proxy because Railway exposes only one port per service. To access it, either:
  - Create a second Railway service pointing at the same repo and configure 3x-ui's subscription port to match its `$PORT`, **or**
  - Set the subscription path to a sub-path of the main panel port in *Panel Settings → Subscription → Sub Path*, so clients reach it via the main port.
