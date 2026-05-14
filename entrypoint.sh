#!/bin/sh
set -e

wait_seconds="${XUI_INIT_WAIT:-5}"
case "$wait_seconds" in
  ''|*[!0-9]*) wait_seconds=5 ;;
esac
if [ "$wait_seconds" -lt 0 ]; then
  wait_seconds=5
fi

echo "⏳ 等待面板数据库初始化..."
sleep "$wait_seconds"

# 通过环境变量设置账号密码（默认 admin / admin）
if [ -n "${XUI_USERNAME:-}" ] && [ -z "${XUI_PASSWORD:-}" ]; then
  echo "⚠️ 仅设置了 XUI_USERNAME，XUI_PASSWORD 将使用默认值 admin" >&2
elif [ -z "${XUI_USERNAME:-}" ] && [ -n "${XUI_PASSWORD:-}" ]; then
  echo "⚠️ 仅设置了 XUI_PASSWORD，XUI_USERNAME 将使用默认值 admin" >&2
elif [ -z "${XUI_USERNAME:-}" ] && [ -z "${XUI_PASSWORD:-}" ]; then
  echo "⚠️ 未设置 XUI_USERNAME/XUI_PASSWORD，将使用默认 admin/admin" >&2
fi

if /usr/local/x-ui/x-ui setting -username "${XUI_USERNAME:-admin}" -password "${XUI_PASSWORD:-admin}" >/dev/null 2>&1; then
  echo "✅ 账号密码已注入"
else
  echo "⚠️ 账号密码注入失败，继续启动 3x-ui"
fi

# 启动 3x-ui 主程序
exec /usr/local/x-ui/x-ui
