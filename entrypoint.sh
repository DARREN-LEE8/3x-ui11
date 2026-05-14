#!/bin/sh
set -e

echo "⏳ 等待面板数据库初始化并注入账号配置..."

# 通过环境变量设置账号密码（默认 admin / admin）
if [ -n "${XUI_USERNAME:-}" ] && [ -z "${XUI_PASSWORD:-}" ]; then
  echo "❌ 仅设置了 XUI_USERNAME，必须同时设置 XUI_PASSWORD"
  exit 1
elif [ -z "${XUI_USERNAME:-}" ] && [ -n "${XUI_PASSWORD:-}" ]; then
  echo "❌ 仅设置了 XUI_PASSWORD，必须同时设置 XUI_USERNAME"
  exit 1
elif [ -z "${XUI_USERNAME:-}" ] && [ -z "${XUI_PASSWORD:-}" ]; then
  echo "⚠️ 未提供 XUI_USERNAME 或 XUI_PASSWORD，使用默认凭据"
fi

username="${XUI_USERNAME:-admin}"
password="${XUI_PASSWORD:-admin}"

max_retries="${XUI_INIT_RETRIES:-30}"
retry_interval="${XUI_INIT_INTERVAL:-1}"
log_interval="${XUI_LOG_INTERVAL:-5}"
attempt=1
configured=false

case "$log_interval" in
  ''|*[!0-9]*|0) log_interval=5 ;;
esac
case "$max_retries" in
  ''|*[!0-9]*|0) max_retries=30 ;;
esac
case "$retry_interval" in
  ''|*[!0-9]*|0) retry_interval=1 ;;
esac

while [ "$attempt" -le "$max_retries" ]; do
  if /usr/local/x-ui/x-ui setting -username "$username" -password "$password" >/dev/null 2>&1; then
    echo "✅ 账号密码已注入"
    configured=true
    break
  fi

  if [ "$attempt" -eq 1 ] || [ $((attempt % log_interval)) -eq 0 ]; then
    echo "⏳ 正在等待面板数据库就绪... (${attempt}/${max_retries})"
  fi

  sleep "$retry_interval"
  attempt=$((attempt + 1))
done

if [ "$configured" != "true" ]; then
  echo "❌ 面板初始化等待超时，账号密码注入失败，终止启动"
  exit 1
fi

# 启动 3x-ui 主程序
exec /usr/local/x-ui/x-ui
